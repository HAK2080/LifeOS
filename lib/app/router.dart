import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'release_notes.dart';
import 'style.dart';

import '../features/equipment/equipment_screen.dart';
import '../features/growth/growth_screen.dart';
import '../features/nutrition/nutrition_screen.dart';
import '../features/nutrition/food_library_screen.dart';
import '../features/nutrition/recipes_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/diagnostics_screen.dart';
import '../features/settings/health_connect_screen.dart';
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
              routes: [
                GoRoute(
                  path: 'foods',
                  builder: (c, s) => const FoodLibraryScreen(),
                ),
                GoRoute(
                  path: 'recipes',
                  builder: (c, s) => const RecipesScreen(),
                ),
              ],
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
    GoRoute(
      path: '/settings',
      builder: (c, s) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'diagnostics',
          builder: (c, s) => const DiagnosticsScreen(),
        ),
        GoRoute(
          path: 'health-connect',
          builder: (c, s) => const HealthConnectScreen(),
        ),
        GoRoute(
          path: 'release-notes',
          builder: (c, s) => const ReleaseNotesScreen(),
        ),
      ],
    ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          final extended = constraints.maxWidth >= 1200;
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: extended,
                    labelType: extended
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    minExtendedWidth: 190,
                    selectedIndex: shell.currentIndex,
                    backgroundColor: scheme.surfaceContainerLow,
                    indicatorColor: scheme.surfaceContainerHighest,
                    selectedIconTheme: IconThemeData(
                      color: scheme.brightness == Brightness.dark
                          ? AppColors.accent
                          : AppColors.accentDeep,
                    ),
                    selectedLabelTextStyle: TextStyle(
                      color: scheme.brightness == Brightness.dark
                          ? AppColors.accent
                          : AppColors.accentDeep,
                      fontWeight: FontWeight.w700,
                    ),
                    onDestinationSelected: _selectBranch,
                    destinations: [
                      for (final tab in _tabs)
                        NavigationRailDestination(
                          icon: Icon(tab.$1),
                          label: Text(tab.$2),
                        ),
                    ],
                  ),
                ),
                VerticalDivider(width: 1, color: scheme.outline),
                Expanded(
                  child: ColoredBox(
                    color: scheme.surface,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: shell,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
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
                          onTap: () => _selectBranch(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectBranch(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
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
    // Mint reads poorly on light paper — use deep green there, mint on ink.
    final color = selected
        ? (scheme.brightness == Brightness.dark
              ? AppColors.accent
              : AppColors.accentDeep)
        : scheme.onSurfaceVariant;
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
