import 'package:flutter/material.dart';

import '../../app/style.dart';

class GrowthScreen extends StatelessWidget {
  const GrowthScreen({super.key});

  static const _tiles = [
    (Icons.bedtime_outlined, 'Sleep'),
    (Icons.psychology_outlined, 'Memory'),
    (Icons.center_focus_strong_outlined, 'Focus'),
    (Icons.spa_outlined, 'Stress'),
    (Icons.air, 'Breathing'),
    (Icons.hot_tub_outlined, 'Sauna'),
    (Icons.ac_unit, 'Cold exposure'),
    (Icons.light_mode_outlined, 'Red-light therapy'),
    (Icons.menu_book_outlined, 'Reading'),
    (Icons.accessibility_new_outlined, 'Mobility'),
    (Icons.favorite_outline, 'Mental wellbeing'),
    (Icons.add_circle_outline, 'Custom habit'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Growth')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text('What do you want to improve?',
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                for (final (icon, title) in _tiles)
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '$title — habit protocols with evidence levels arrive in Phase 4. No streak pressure, ever.')),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: AppColors.accent),
                        const SizedBox(height: 8),
                        Text(title,
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
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
