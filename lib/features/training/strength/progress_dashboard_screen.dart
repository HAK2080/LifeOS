import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/style.dart';
import '../training_repository.dart';

class ProgressDashboardScreen extends ConsumerStatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  ConsumerState<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState
    extends ConsumerState<ProgressDashboardScreen> {
  late Future<(List<dynamic>, List<PersonalRecord>)> _load;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final repo = ref.read(trainingRepositoryProvider);
    _load = Future.wait<dynamic>([repo.recentVolume(), repo.personalRecords()])
        .then(
          (values) =>
              (values[0] as List<dynamic>, values[1] as List<PersonalRecord>),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress & records'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(_refresh),
          ),
        ],
      ),
      body: FutureBuilder<(List<dynamic>, List<PersonalRecord>)>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load progress: ${snapshot.error}'),
            );
          }
          final volumes = snapshot.data!.$1;
          final records = snapshot.data!.$2;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              AppCard(
                tinted: true,
                child: Text(
                  'Use this as a calm review of recent training. Volume landmarks are adjustable heuristics, not targets you must reach.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Last 7 days · completed sets',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (volumes.isEmpty)
                const AppCard(
                  child: Text('Finish a workout to see volume here.'),
                )
              else
                for (final volume in volumes.cast<dynamic>())
                  _VolumeCard(volume: volume),
              const SizedBox(height: 20),
              Text(
                'Personal records',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (records.isEmpty)
                const AppCard(
                  child: Text(
                    'Logged sets with weight and reps will appear here.',
                  ),
                )
              else
                for (final record in records.take(30))
                  _RecordCard(record: record),
            ],
          );
        },
      ),
    );
  }
}

class _VolumeCard extends StatelessWidget {
  const _VolumeCard({required this.volume});

  final dynamic volume;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  volume.muscleGroup.toString().toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  volume.guidance,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${volume.sets} sets',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_outlined, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.exerciseName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Best logged set · ${DateFormat.yMMMd().format(record.lastPerformed)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${_fmt(record.maxWeightKg)} kg × ${record.bestReps}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  String _fmt(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
}
