import 'package:flutter/material.dart';

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
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Icon(icon,
                    size: 30, color: Theme.of(context).colorScheme.primary),
                title: Text(title),
                subtitle: Text(blurb),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Nutrition logging arrives in Phase 3 — low-friction, not obsessive.')),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
