import 'package:flutter/material.dart';

import '../../app/neon.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  static const _entries = [
    (Icons.camera_alt_outlined, 'LOG MEAL', 'Photo, voice, text or manual'),
    (Icons.bolt_outlined, 'QUICK LOG', 'Your frequent meals, one tap'),
    (Icons.bookmark_outline, 'SAVED MEALS', 'Reuse, pin and adjust portions'),
    (Icons.donut_small_outlined, "TODAY'S INTAKE", 'Calories and macros so far'),
    (Icons.flag_outlined, 'GOALS', 'Targets you approve — never automatic'),
    (Icons.trending_up, 'PROGRESS', 'Weight and trend, reviewed gently'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NUTRITION')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (icon, title, blurb) in _entries)
            NeonCard(
              accent: Neon.lime,
              margin: const EdgeInsets.only(bottom: 14),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Nutrition logging arrives in Phase 3 — low-friction, not obsessive.')),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 30, color: Neon.lime, shadows: [
                    Shadow(
                        color: Neon.lime.withValues(alpha: 0.8),
                        blurRadius: 16),
                  ]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: Neon.lime)),
                        const SizedBox(height: 4),
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
