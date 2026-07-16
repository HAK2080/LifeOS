import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainingTile {
  const TrainingTile(this.id, this.title, this.icon, this.blurb);

  final String id;
  final String title;
  final IconData icon;
  final String blurb;
}

const _allTiles = [
  TrainingTile('strength', 'Strength / Hypertrophy', Icons.fitness_center,
      'Log sets, follow your plan at your own pace.'),
  TrainingTile('wod', 'WOD / Conditioning', Icons.timer_outlined,
      'Coach-designed or equipment-led conditioning.'),
  TrainingTile('kettlebell', 'Kettlebell', Icons.sports_gymnastics,
      'Complexes, EMOM, AMRAP, technique.'),
  TrainingTile('zone2', 'Zone 2', Icons.monitor_heart_outlined,
      'Easy aerobic work — weekly minutes across activities.'),
  TrainingTile('walking', 'Walking', Icons.directions_walk,
      'Steps, treadmill and rucking.'),
  TrainingTile('mobility', 'Mobility / Recovery', Icons.self_improvement,
      'Stretching, foam rolling, breathing.'),
];

final tileOrderProvider =
    AsyncNotifierProvider<TileOrderNotifier, List<String>>(
        TileOrderNotifier.new);

class TileOrderNotifier extends AsyncNotifier<List<String>> {
  static const _key = 'training_tile_order';

  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key);
    final defaults = _allTiles.map((t) => t.id).toList();
    if (saved == null) return defaults;
    // Keep only known ids, append any new tiles at the end.
    final known = saved.where(defaults.contains).toList();
    for (final d in defaults) {
      if (!known.contains(d)) known.add(d);
    }
    return known;
  }

  Future<void> move(int oldIndex, int newIndex) async {
    // newIndex is already adjusted for the removed item (onReorderItem).
    final order = [...state.value ?? []];
    final item = order.removeAt(oldIndex);
    order.insert(newIndex, item);
    state = AsyncData(List<String>.from(order));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, List<String>.from(order));
  }
}

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(tileOrderProvider);
    final order = orderAsync.value ?? _allTiles.map((t) => t.id).toList();
    final tiles = [
      for (final id in order) _allTiles.firstWhere((t) => t.id == id)
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training'),
        actions: [
          IconButton(
            tooltip: 'Equipment library',
            icon: const Icon(Icons.handyman_outlined),
            onPressed: () => context.go('/training/equipment'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('What do you feel like doing today?',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: tiles.length,
              onReorderItem: (o, n) =>
                  ref.read(tileOrderProvider.notifier).move(o, n),
              itemBuilder: (context, i) {
                final t = tiles[i];
                return Card(
                  key: ValueKey(t.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    leading: Icon(t.icon,
                        size: 32, color: Theme.of(context).colorScheme.primary),
                    title: Text(t.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(t.blurb),
                    trailing: ReorderableDragStartListener(
                      index: i,
                      child: const Icon(Icons.drag_handle),
                    ),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => _ComingSoonSheet(tile: t),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonSheet extends StatelessWidget {
  const _ComingSoonSheet({required this.tile});

  final TrainingTile tile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tile.icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(tile.title,
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            Text(tile.blurb),
            const SizedBox(height: 8),
            Text(
              'This module arrives in Phase 2 — logging, plans, rest timers '
              'and coach-assisted progression. The tile order you set here '
              'is already saved.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
