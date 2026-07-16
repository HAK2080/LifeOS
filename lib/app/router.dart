import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'style.dart';

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
    (Icons.check_circle_outline, 'Tasks'),
    (Icons.wb_sunny_outlined, 'Today'),
    (Icons.fitness_center_outlined, 'Training'),
    (Icons.restaurant_outlined, 'Nutrition'),
    (Icons.spa_outlined, 'Growth'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          border: Border(top: BorderSide(color: scheme.outline)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: _tabs[i].$1,
                      label: _tabs[i].$2,
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
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? AppColors.accent : scheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Sans',
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
