import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/style.dart';
import '../training_repository.dart';
import 'plans_screen.dart' show plansProvider;
import 'strength_content.dart';

class ProgressiveOverloadScreen extends ConsumerWidget {
  const ProgressiveOverloadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider);
    final plans = ref.watch(plansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progressive overload')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            tinted: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optional strength method',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use a rep range, record reps in reserve (RIR), and progress only when the work stays controlled. It is a method you can choose per exercise, not a required schedule.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your training system',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The method is connected to your offline exercise library, plans, and logged sessions.',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        label: 'Exercises',
                        value: exercises.when(
                          data: (items) => '${items.length}',
                          loading: () => '…',
                          error: (_, _) => '—',
                        ),
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        label: 'My plans',
                        value: plans.when(
                          data: (items) => '${items.length}',
                          loading: () => '…',
                          error: (_, _) => '—',
                        ),
                      ),
                    ),
                    Expanded(
                      child: _Metric(
                        label: 'Starter plans',
                        value: '${starterTemplates.length}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.fitness_center_outlined),
                      label: const Text('Exercise library'),
                      onPressed: () =>
                          context.go('/training/strength/exercises'),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.view_list_outlined),
                      label: const Text('Plans'),
                      onPressed: () => context.go('/training/strength/plans'),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.insights_outlined),
                      label: const Text('Progress & records'),
                      onPressed: () =>
                          context.go('/training/strength/progress'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'How the method works',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const _MethodStep(
            number: '1',
            title: 'Choose a range',
            body:
                'Set a practical rep range such as 8–12 and a manageable number of sets.',
          ),
          const _MethodStep(
            number: '2',
            title: 'Log RIR and pain',
            body:
                'Record how many good reps you had left. Pain overrides progression; reduce load or stop and reassess.',
          ),
          const _MethodStep(
            number: '3',
            title: 'Add reps before load',
            body:
                'Stay at the same load while reps rise through the range. When all sets reach the top, add the smallest sensible increment and rebuild.',
          ),
          const _MethodStep(
            number: '4',
            title: 'Review volume gently',
            body:
                'Use recent history and recovery to decide whether volume is too little, useful, or too much. No automatic deload is forced.',
          ),
          const SizedBox(height: 8),
          Text(
            'Reference: simmahon/progressive-overload-app (RP Strength-inspired public project). This screen is an independent offline Flutter implementation; no source code is embedded.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.tune),
            label: const Text('Choose this for a plan exercise'),
            onPressed: () => context.go('/training/strength/plans'),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.accent,
            child: Text(number, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
