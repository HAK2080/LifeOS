import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/backup/data_export_service.dart';
import '../../core/database/database_provider.dart';

class ProfileData {
  const ProfileData({this.weightKg, this.heightCm, this.age, this.goal});

  final double? weightKg;
  final double? heightCm;
  final int? age;
  final String? goal;
}

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileData>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<ProfileData> {
  @override
  Future<ProfileData> build() async {
    final p = await SharedPreferences.getInstance();
    return ProfileData(
      weightKg: p.getDouble('profile_weight'),
      heightCm: p.getDouble('profile_height'),
      age: p.getInt('profile_age'),
      goal: p.getString('profile_goal'),
    );
  }

  Future<void> save(
      {double? weightKg, double? heightCm, int? age, String? goal}) async {
    final p = await SharedPreferences.getInstance();
    if (weightKg != null) await p.setDouble('profile_weight', weightKg);
    if (heightCm != null) await p.setDouble('profile_height', heightCm);
    if (age != null) await p.setInt('profile_age', age);
    if (goal != null) await p.setString('profile_goal', goal);
    ref.invalidateSelf();
  }
}

final notificationsEnabledProvider =
    AsyncNotifierProvider<NotificationsEnabledNotifier, bool>(
        NotificationsEnabledNotifier.new);

class NotificationsEnabledNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('notifications_enabled') ?? true;
  }

  Future<void> set(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('notifications_enabled', value);
    state = AsyncData(value);
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value ?? const ProfileData();
    final notifs = ref.watch(notificationsEnabledProvider).value ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _numTile(context, ref, 'Weight (kg)', profile.weightKg,
                    (v) => ref.read(profileProvider.notifier).save(weightKg: v)),
                _numTile(context, ref, 'Height (cm)', profile.heightCm,
                    (v) => ref.read(profileProvider.notifier).save(heightCm: v)),
                _numTile(
                    context,
                    ref,
                    'Age',
                    profile.age?.toDouble(),
                    (v) => ref
                        .read(profileProvider.notifier)
                        .save(age: v.round())),
                ListTile(
                  title: const Text('Goal'),
                  subtitle: Text(profile.goal ?? 'Not set'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickGoal(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: const Text('Allow reminders'),
              subtitle: const Text(
                  'Only reminders you set yourself. Never guilt-based.'),
              value: notifs,
              onChanged: (v) =>
                  ref.read(notificationsEnabledProvider.notifier).set(v),
            ),
          ),
          const SizedBox(height: 24),
          Text('Privacy', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PrivacyPoint(
                      'All data lives on this device. No account, no cloud.'),
                  _PrivacyPoint(
                      'Photos (meals, equipment, machine consoles, progress) are processed temporarily and deleted after analysis.'),
                  _PrivacyPoint(
                      'Progress photos store only the estimate, date, trend and confidence — never the image.'),
                  _PrivacyPoint(
                      'Optional encrypted backup arrives in a later phase.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.ios_share_outlined),
              title: const Text('Export local data'),
              subtitle: const Text('Share a readable backup of this device data'),
              onTap: () => _exportData(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await DataExportService(ref.read(databaseProvider)).share();
      if (!context.mounted || result.status == ShareResultStatus.dismissed) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local backup ready to share.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not export local data.')),
      );
    }
  }

  Widget _numTile(BuildContext context, WidgetRef ref, String label,
      double? value, void Function(double) onSave) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value == null
          ? 'Not set'
          : (value == value.roundToDouble()
              ? value.round().toString()
              : value.toStringAsFixed(1))),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final controller = TextEditingController(
            text: value == null ? '' : value.toString());
        final result = await showDialog<double>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(label),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(c, double.tryParse(controller.text)),
                child: const Text('Save'),
              ),
            ],
          ),
        );
        if (result != null) onSave(result);
      },
    );
  }

  Future<void> _pickGoal(BuildContext context, WidgetRef ref) async {
    const goals = [
      'Lose fat',
      'Build muscle',
      'Recomposition',
      'Maintain',
      'General health'
    ];
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final g in goals)
              ListTile(title: Text(g), onTap: () => Navigator.pop(c, g)),
          ],
        ),
      ),
    );
    if (picked != null) {
      await ref.read(profileProvider.notifier).save(goal: picked);
    }
  }
}

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline,
              size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
