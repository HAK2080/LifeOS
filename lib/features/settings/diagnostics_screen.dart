import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/build_info.dart';
import '../../app/style.dart';
import '../../core/database/database_provider.dart';
import '../../core/health/health_service.dart';
import 'settings_screen.dart';

class DiagnosticData {
  const DiagnosticData({
    required this.schemaVersion,
    required this.tasks,
    required this.workouts,
    required this.foods,
    required this.recipes,
    required this.habits,
    required this.goals,
  });

  final int schemaVersion;
  final int tasks;
  final int workouts;
  final int foods;
  final int recipes;
  final int habits;
  final int goals;
}

final diagnosticDataProvider = FutureProvider.autoDispose<DiagnosticData>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final results = await Future.wait<int>([
    db.select(db.tasks).get().then((rows) => rows.length),
    db.select(db.workoutSessions).get().then((rows) => rows.length),
    db.select(db.foods).get().then((rows) => rows.length),
    db.select(db.recipes).get().then((rows) => rows.length),
    db.select(db.habits).get().then((rows) => rows.length),
    db.select(db.goals).get().then((rows) => rows.length),
  ]);
  return DiagnosticData(
    schemaVersion: db.schemaVersion,
    tasks: results[0],
    workouts: results[1],
    foods: results[2],
    recipes: results[3],
    habits: results[4],
    goals: results[5],
  );
});

class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(diagnosticDataProvider);
    final health = ref.watch(healthConnectionProvider).value;
    final notifications = ref.watch(notificationsEnabledProvider).value ?? true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            tooltip: 'Refresh diagnostics',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(diagnosticDataProvider);
              ref.read(healthConnectionProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: data.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Could not load diagnostics: $error')),
            data: (snapshot) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppCard(
                  tinted: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppBuildInfo.label,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Platform: ${kIsWeb ? 'Web preview' : defaultTargetPlatform.name}',
                      ),
                      Text('Database schema: ${snapshot.schemaVersion}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _DiagnosticCard(
                  title: 'Services',
                  rows: {
                    'Notifications': notifications ? 'Enabled' : 'Paused',
                    'Health Connect': _healthLabel(health),
                    'Health sync': health?.syncEnabled == true
                        ? 'Enabled'
                        : 'Paused / unavailable',
                    'Last health sync': health?.lastSync == null
                        ? 'Never'
                        : DateFormat.yMMMd().add_jm().format(health!.lastSync!),
                  },
                ),
                const SizedBox(height: 12),
                _DiagnosticCard(
                  title: 'Local data',
                  rows: {
                    'Tasks': '${snapshot.tasks}',
                    'Workouts': '${snapshot.workouts}',
                    'Foods': '${snapshot.foods}',
                    'Recipes': '${snapshot.recipes}',
                    'Habits': '${snapshot.habits}',
                    'Goals': '${snapshot.goals}',
                  },
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.ios_share_outlined),
                  label: const Text('Export diagnostic report'),
                  onPressed: () =>
                      _share(context, snapshot, health, notifications),
                ),
                const SizedBox(height: 8),
                Text(
                  'The report contains technical status and row counts only. It does not include task names, meals, notes, or health values.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _healthLabel(HealthConnectionSnapshot? health) {
    if (health == null) return 'Checking';
    return switch (health.availability) {
      HealthConnectionAvailability.available =>
        health.permissionsGranted
            ? 'Connected'
            : 'Available · permission needed',
      HealthConnectionAvailability.updateRequired => 'Update required',
      HealthConnectionAvailability.unavailable => 'Unavailable',
    };
  }

  Future<void> _share(
    BuildContext context,
    DiagnosticData data,
    HealthConnectionSnapshot? health,
    bool notifications,
  ) async {
    final report =
        '''
LifeOS diagnostic report
${AppBuildInfo.label}
Platform: ${kIsWeb ? 'Web preview' : defaultTargetPlatform.name}
Database schema: ${data.schemaVersion}
Notifications: ${notifications ? 'enabled' : 'paused'}
Health Connect: ${_healthLabel(health)}
Health sync: ${health?.syncEnabled == true ? 'enabled' : 'paused / unavailable'}
Tasks: ${data.tasks}
Workouts: ${data.workouts}
Foods: ${data.foods}
Recipes: ${data.recipes}
Habits: ${data.habits}
Goals: ${data.goals}
'''
            .trim();
    try {
      await SharePlus.instance.share(
        ShareParams(text: report, subject: 'LifeOS diagnostics'),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share diagnostics.')),
      );
    }
  }
}

class _DiagnosticCard extends StatelessWidget {
  const _DiagnosticCard({required this.title, required this.rows});

  final String title;
  final Map<String, String> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          for (final row in rows.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Expanded(child: Text(row.key)),
                  Text(
                    row.value,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
