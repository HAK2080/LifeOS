import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'neon.dart';

import '../features/equipment/equipment_screen.dart';
import '../features/growth/growth_screen.dart';
import '../features/nutrition/nutrition_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../features/today/today_screen.dart';
import '../features/training/training_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/today',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/tasks', builder: (c, s) => const TasksScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/today', builder: (c, s) => const TodayScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/training',
            builder: (c, s) => const TrainingScreen(),
            routes: [
              GoRoute(
                path: 'equipment',
                builder: (c, s) => const EquipmentScreen(),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/nutrition', builder: (c, s) => const NutritionScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/growth', builder: (c, s) => const GrowthScreen()),
        ]),
      ],
    ),
    GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (Icons.check_circle_outline, 'Tasks', Neon.cyan),
    (Icons.wb_sunny_outlined, 'Today', Neon.gold),
    (Icons.fitness_center_outlined, 'Training', Neon.ember),
    (Icons.restaurant_outlined, 'Nutrition', Neon.lime),
    (Icons.spa_outlined, 'Growth', Neon.violet),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Neon.surface,
          border: Border(
            top: BorderSide(color: Neon.cyan.withValues(alpha: 0.25)),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: _tabs[i].$1,
                      label: _tabs[i].$2,
                      accent: _tabs[i].$3,
                      selected: shell.currentIndex == i,
                      onTap: () => shell.goBranch(i,
                          initialLocation: i == shell.currentIndex),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? accent : Neon.dim;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: selected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: accent.withValues(alpha: 0.55),
                            blurRadius: 18),
                      ],
                    )
                  : null,
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rajdhani',
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
