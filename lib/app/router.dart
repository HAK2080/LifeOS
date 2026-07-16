import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.check_circle_outline), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.wb_sunny_outlined), label: 'Today'),
          NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined), label: 'Training'),
          NavigationDestination(
              icon: Icon(Icons.restaurant_outlined), label: 'Nutrition'),
          NavigationDestination(icon: Icon(Icons.spa_outlined), label: 'Growth'),
        ],
      ),
    );
  }
}
