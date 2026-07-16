import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'style.dart';

import '../features/equipment/equipment_screen.dart';
import '../features/growth/growth_screen.dart';
import '../features/nutrition/nutrition_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../features/today/today_screen.dart';
import '../features/training/cardio/mobility_screen.dart';
import '../features/training/cardio/walking_screen.dart';
import '../features/training/cardio/zone2_screen.dart';
import '../features/training/strength/exercise_history_screen.dart';
import '../features/training/strength/exercise_library_screen.dart';
import '../features/training/strength/plans_screen.dart';
import '../features/training/strength/progress_dashboard_screen.dart';
import '../features/training/strength/progressive_overload_screen.dart';
import '../features/training/strength/strength_screen.dart';
import '../features/training/strength/workout_session_screen.dart';
import '../features/training/training_screen.dart';
import '../features/training/wod/kettlebell_screen.dart';
import '../features/training/wod/wod_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/today',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/tasks', builder: (c, s) => const TasksScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/today', builder: (c, s) => const TodayScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/training',
              builder: (c, s) => const TrainingScreen(),
              routes: [
                GoRoute(
                  path: 'equipment',
                  builder: (c, s) => const EquipmentScreen(),
                ),
                GoRoute(
                  path: 'strength',
                  builder: (c, s) => const StrengthScreen(),
                  routes: [
                    GoRoute(
                      path: 'session/:id',
                      builder: (c, s) => WorkoutSessionScreen(
                        sessionId: int.parse(s.pathParameters['id']!),
                      ),
                    ),
                    GoRoute(
                      path: 'history',
                      builder: (c, s) => const ExerciseHistoryScreen(),
                    ),
                    GoRoute(
                      path: 'exercises',
                      builder: (c, s) => const ExerciseLibraryScreen(),
                    ),
                    GoRoute(
                      path: 'progress',
                      builder: (c, s) => const ProgressDashboardScreen(),
                    ),
                    GoRoute(
                      path: 'plans',
                      builder: (c, s) => const PlansScreen(),
                    ),
                    GoRoute(
                      path: 'progressive-overload',
                      builder: (c, s) => const ProgressiveOverloadScreen(),
                    ),
                  ],
                ),
                GoRoute(path: 'wod', builder: (c, s) => const WodScreen()),
                GoRoute(
                  path: 'kettlebell',
                  builder: (c, s) => const KettlebellScreen(),
                ),
                GoRoute(path: 'zone2', builder: (c, s) => const Zone2Screen()),
                GoRoute(
                  path: 'walking',
                  builder: (c, s) => const WalkingScreen(),
                ),
                GoRoute(
                  path: 'mobility',
                  builder: (c, s) => const MobilityScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/nutrition',
              builder: (c, s) => const NutritionScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/growth', builder: (c, s) => const GrowthScreen()),
          ],
        ),
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
            height: 72,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: _tabs[i].$1,
                      label: _tabs[i].$2,
                      selected: shell.currentIndex == i,
                      onTap: () => shell.goBranch(
                        i,
                        initialLocation: i == shell.currentIndex,
                      ),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? scheme.surfaceContainerHighest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Sans',
                  fontSize: 10,
                  letterSpacing: .5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
