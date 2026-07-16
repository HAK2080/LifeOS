import 'package:flutter/material.dart';

import '../../app/style.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  static const _entries = [
    (Icons.camera_alt_outlined, 'Log Meal', 'Photo, voice, text or manual'),
    (Icons.bolt_outlined, 'Quick Log', 'Your frequent meals, one tap'),
    (Icons.bookmark_outline, 'Saved Meals', 'Reuse, pin and adjust portions'),
    (Icons.donut_small_outlined, "Today's Intake", 'Calories and macros so far'),
    (Icons.flag_outlined, 'Goals', 'Targets you approve — never automatic'),
    (Icons.trending_up, 'Progress', 'Weight and trend, reviewed gently'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (icon, title, blurb) in _entries)
            AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Nutrition logging arrives in Phase 3 — low-friction, not obsessive.')),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 26, color: AppColors.accent),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 3),
                        Text(blurb,
                            style: Theme.of(context).textTheme.bodySmall),
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
