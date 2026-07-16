import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'today_data.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: const [
          _AyahCard(),
          SizedBox(height: 16),
          _GoodDeedCard(),
          SizedBox(height: 16),
          _CheckInCard(),
          SizedBox(height: 16),
          _FocusCard(),
        ],
      ),
    );
  }
}

class _AyahCard extends ConsumerStatefulWidget {
  const _AyahCard();

  @override
  ConsumerState<_AyahCard> createState() => _AyahCardState();
}

class _AyahCardState extends ConsumerState<_AyahCard> {
  bool showSource = false;

  @override
  Widget build(BuildContext context) {
    final ayah = ref.watch(ayahOfDayProvider);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ayah.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Text('تعذر تحميل آية اليوم'),
          data: (a) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('آية اليوم',
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.primary)),
              const SizedBox(height: 12),
              Text(
                a.text,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(height: 1.8),
              ),
              const SizedBox(height: 8),
              Text(
                '﴿${a.surah} ${a.ayahNumber}﴾',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const Divider(height: 24),
              Text(
                a.tafsir,
                textDirection: TextDirection.rtl,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
              ),
              if (showSource) ...[
                const SizedBox(height: 8),
                Text(
                  a.source,
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => showSource = !showSource),
                  child: Text(showSource ? 'إخفاء المصدر' : 'المصدر'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoodDeedCard extends ConsumerWidget {
  const _GoodDeedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deeds = ref.watch(todayDeedsProvider).value ?? [];
    final repo = ref.read(todayRepositoryProvider);
    final theme = Theme.of(context);
    final suggestion =
        goodDeedSuggestions[rotationIndex(DateTime.now(), goodDeedSuggestions.length)];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('عمل الخير اليوم',
                textDirection: TextDirection.rtl,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 8),
            Text('ما العمل الصالح الذي تريد أن تفعله اليوم؟',
                textDirection: TextDirection.rtl,
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              textDirection: TextDirection.rtl,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(suggestion, textDirection: TextDirection.rtl),
                  onPressed: () =>
                      repo.addDeed(dayKey(DateTime.now()), suggestion),
                ),
                ActionChip(
                  avatar: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('عمل آخر...', textDirection: TextDirection.rtl),
                  onPressed: () => _addCustomDeed(context, repo),
                ),
              ],
            ),
            for (final d in deeds)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: d.done,
                onChanged: (v) => repo.setDeedDone(d.id, v ?? false),
                title: Text(
                  d.title,
                  textDirection: TextDirection.rtl,
                  style: d.done
                      ? const TextStyle(decoration: TextDecoration.lineThrough)
                      : null,
                ),
                secondary: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => repo.deleteDeed(d.id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCustomDeed(BuildContext context, TodayRepository repo) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('عمل الخير', textDirection: TextDirection.rtl),
        content: TextField(
          controller: controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
          onSubmitted: (v) => Navigator.pop(c, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(c, controller.text),
              child: const Text('إضافة')),
        ],
      ),
    );
    if (text != null && text.trim().isNotEmpty) {
      await repo.addDeed(dayKey(DateTime.now()), text.trim());
    }
  }
}

class _CheckInCard extends ConsumerWidget {
  const _CheckInCard();

  static const _labels = ['Mood', 'Energy', 'Physical'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkIn = ref.watch(todayCheckInProvider).value;
    final repo = ref.read(todayRepositoryProvider);
    final values = [checkIn?.mood, checkIn?.energy, checkIn?.physical];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick check-in',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 4),
            Text('Optional — skip anything you like.',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            for (var i = 0; i < 3; i++) ...[
              Row(
                children: [
                  SizedBox(
                      width: 72,
                      child: Text(_labels[i],
                          style: Theme.of(context).textTheme.bodyMedium)),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var v = 1; v <= 5; v++)
                          _Dot(
                            selected: values[i] == v,
                            value: v,
                            onTap: () => repo.setCheckIn(
                              dayKey(DateTime.now()),
                              mood: i == 0 ? v : null,
                              energy: i == 1 ? v : null,
                              physical: i == 2 ? v : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (i < 2) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.selected, required this.value, required this.onTap});

  final bool selected;
  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? scheme.primary : scheme.surfaceContainerHighest,
        ),
        child: Text(
          '$value',
          style: TextStyle(
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _FocusCard extends ConsumerWidget {
  const _FocusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(todayFocusProvider).value;
    final repo = ref.read(todayRepositoryProvider);
    final theme = Theme.of(context);
    final day = dayKey(DateTime.now());
    final suggestion =
        focusSuggestions[rotationIndex(DateTime.now(), focusSuggestions.length)];

    Widget body;
    if (focus == null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(suggestion, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: () => repo.setFocus(day, suggestion),
                child: const Text('Sounds good'),
              ),
              OutlinedButton(
                onPressed: () => _chooseOwn(context, repo, day),
                child: const Text('Choose my own'),
              ),
              TextButton(
                onPressed: () {
                  final next = focusSuggestions[
                      (focusSuggestions.indexOf(suggestion) + 1) %
                          focusSuggestions.length];
                  repo.setFocus(day, next);
                },
                child: const Text('Something else'),
              ),
            ],
          ),
        ],
      );
    } else if (focus.status == 'completed') {
      body = Row(
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text('${focus.title} — done. Nice.',
                style: theme.textTheme.bodyLarge),
          ),
        ],
      );
    } else if (focus.status == 'skipped') {
      body = Row(
        children: [
          const Icon(Icons.bedtime_outlined),
          const SizedBox(width: 12),
          const Expanded(child: Text('Skipped for today — no problem.')),
          TextButton(
            onPressed: () => repo.setFocusStatus(day, 'pending'),
            child: const Text('Undo'),
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(focus.title, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(
                onPressed: () => repo.setFocusStatus(day, 'completed'),
                child: const Text('Done'),
              ),
              OutlinedButton(
                onPressed: () => _chooseOwn(context, repo, day),
                child: const Text('Change'),
              ),
              TextButton(
                onPressed: () => repo.setFocusStatus(day, 'skipped'),
                child: const Text('Skip today'),
              ),
            ],
          ),
        ],
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's focus",
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            body,
          ],
        ),
      ),
    );
  }

  Future<void> _chooseOwn(
      BuildContext context, TodayRepository repo, String day) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Today's focus"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'One small useful thing'),
          onSubmitted: (v) => Navigator.pop(c, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, controller.text),
              child: const Text('Set')),
        ],
      ),
    );
    if (text != null && text.trim().isNotEmpty) {
      await repo.setFocus(day, text.trim());
    }
  }
}
