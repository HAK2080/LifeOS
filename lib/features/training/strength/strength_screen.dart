import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/style.dart';
import '../training_repository.dart';
import 'exercise_picker.dart';

class StrengthScreen extends ConsumerWidget {
  const StrengthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSessionProvider).value;
    final repo = ref.read(trainingRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Strength')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (active != null) ...[
            AppCard(
              tinted: true,
              onTap: () =>
                  context.go('/training/strength/session/${active.id}'),
              child: Row(
                children: [
                  const Icon(Icons.play_circle, color: AppColors.accent),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resume ${active.title}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Started ${DateFormat.jm().format(active.startedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          _MenuTile(
            icon: Icons.play_arrow_outlined,
            title: 'Start Empty Workout',
            blurb: 'Open a blank session, add exercises as you go',
            onTap: () async {
              final id = await repo.startSession();
              if (context.mounted) {
                context.go('/training/strength/session/$id');
              }
            },
          ),
          _MenuTile(
            icon: Icons.checklist_outlined,
            title: 'Choose Exercises',
            blurb: 'Pick exercises first, then start logging',
            onTap: () async {
              final picked = await pickExercise(context, ref);
              if (picked == null || !context.mounted) return;
              final id = await repo.startSession();
              await repo.addExerciseToSession(id, picked);
              if (context.mounted) {
                context.go('/training/strength/session/$id');
              }
            },
          ),
          _MenuTile(
            icon: Icons.route_outlined,
            title: 'Continue Training Plan',
            blurb: 'Pick up the next workout in your plan',
            onTap: () => context.go('/training/strength/plans'),
          ),
          _MenuTile(
            icon: Icons.view_list_outlined,
            title: 'Exercise Library',
            blurb: 'Browse, filter, and add exercises for your plans',
            onTap: () => context.go('/training/strength/exercises'),
          ),
          _MenuTile(
            icon: Icons.insights_outlined,
            title: 'Progress & Records',
            blurb: 'Review recent volume and your best logged sets',
            onTap: () => context.go('/training/strength/progress'),
          ),
          _MenuTile(
            icon: Icons.trending_up,
            title: 'Progressive Overload Method',
            blurb: 'Optional RIR-based progression with rep ranges and reviews',
            onTap: () => context.go('/training/strength/progressive-overload'),
          ),
          _MenuTile(
            icon: Icons.edit_note_outlined,
            title: 'Create / Edit Training Plan',
            blurb: 'Your plans, your structure — nothing forced',
            onTap: () => context.go('/training/strength/plans'),
          ),
          _MenuTile(
            icon: Icons.history,
            title: 'Exercise History',
            blurb: 'Every set you have logged, by exercise',
            onTap: () => context.go('/training/strength/history'),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.blurb,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String blurb;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 26, color: AppColors.accent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(blurb, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
