import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/neon.dart';
import 'today_data.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODAY'),
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
    return NeonCard(
      accent: Neon.gold,
      child: ayah.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Neon.gold)),
        error: (e, _) => const Text('تعذر تحميل آية اليوم',
            textDirection: TextDirection.rtl),
        data: (a) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: AlignmentDirectional.centerEnd,
              child: NeonTitle('آية اليوم', accent: Neon.gold, arabic: true),
            ),
            const SizedBox(height: 14),
            Text(
              a.text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 24,
                height: 1.9,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFFE9B8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '﴿${a.surah} ${a.ayahNumber}﴾',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Neon.gold.withValues(alpha: 0.8)),
            ),
            Divider(height: 24, color: Neon.gold.withValues(alpha: 0.2)),
            Text(
              a.tafsir,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15.5,
                  height: 1.8,
                  color: Neon.ice),
            ),
            if (showSource) ...[
              const SizedBox(height: 8),
              Text(
                a.source,
                textDirection: TextDirection.rtl,
                style: theme.textTheme.bodySmall,
              ),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: Neon.gold),
                onPressed: () => setState(() => showSource = !showSource),
                child: Text(showSource ? 'إخفاء المصدر' : 'المصدر'),
              ),
            ),
          ],
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
    final suggestion = goodDeedSuggestions[
        rotationIndex(DateTime.now(), goodDeedSuggestions.length)];

    return NeonCard(
      accent: Neon.lime,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerEnd,
            child:
                NeonTitle('عمل الخير اليوم', accent: Neon.lime, arabic: true),
          ),
          const SizedBox(height: 8),
          const Text('ما العمل الصالح الذي تريد أن تفعله اليوم؟',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontFamily: 'Tajawal', fontSize: 15, color: Neon.ice)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            textDirection: TextDirection.rtl,
            children: [
              ActionChip(
                avatar: const Icon(Icons.add, size: 18, color: Neon.lime),
                side: BorderSide(color: Neon.lime.withValues(alpha: 0.5)),
                label: Text(suggestion, textDirection: TextDirection.rtl),
                onPressed: () =>
                    repo.addDeed(dayKey(DateTime.now()), suggestion),
              ),
              ActionChip(
                avatar:
                    const Icon(Icons.edit_outlined, size: 18, color: Neon.lime),
                side: BorderSide(color: Neon.lime.withValues(alpha: 0.5)),
                label:
                    const Text('عمل آخر...', textDirection: TextDirection.rtl),
                onPressed: () => _addCustomDeed(context, repo),
              ),
            ],
          ),
          for (final d in deeds)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              checkboxShape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              side: BorderSide(
                  color: Neon.lime.withValues(alpha: 0.7), width: 1.6),
              activeColor: Neon.lime,
              checkColor: Colors.black,
              value: d.done,
              onChanged: (v) => repo.setDeedDone(d.id, v ?? false),
              title: Text(
                d.title,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: d.done ? Neon.dim : Neon.ice,
                  decoration: d.done ? TextDecoration.lineThrough : null,
                  decorationColor: Neon.lime,
                ),
              ),
              secondary: IconButton(
                icon: const Icon(Icons.close, size: 18, color: Neon.dim),
                onPressed: () => repo.deleteDeed(d.id),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addCustomDeed(BuildContext context, TodayRepository repo) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('عمل الخير',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Tajawal')),
        content: TextField(
          controller: controller,
          autofocus: true,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontFamily: 'Tajawal'),
          onSubmitted: (v) => Navigator.pop(c, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('إلغاء')),
          NeonButton(
              label: 'إضافة',
              accent: Neon.lime,
              onPressed: () => Navigator.pop(c, controller.text)),
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
  static const _accents = [Neon.cyan, Neon.magenta, Neon.ember];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkIn = ref.watch(todayCheckInProvider).value;
    final repo = ref.read(todayRepositoryProvider);
    final values = [checkIn?.mood, checkIn?.energy, checkIn?.physical];

    return NeonCard(
      accent: Neon.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeonTitle('CHECK-IN', accent: Neon.cyan),
          const SizedBox(height: 4),
          Text('Optional — skip anything you like.',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          for (var i = 0; i < 3; i++) ...[
            Row(
              children: [
                SizedBox(
                    width: 76,
                    child: Text(_labels[i],
                        style: const TextStyle(
                            fontFamily: 'Rajdhani',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Neon.ice))),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var v = 1; v <= 5; v++)
                        _Dot(
                          selected: values[i] == v,
                          value: v,
                          accent: _accents[i],
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
            if (i < 2) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(
      {required this.selected,
      required this.value,
      required this.accent,
      required this.onTap});

  final bool selected;
  final int value;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? accent.withValues(alpha: 0.2) : Neon.surfaceHi,
          border: Border.all(
            color: selected ? accent : Neon.dim.withValues(alpha: 0.4),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 14)]
              : null,
        ),
        child: Text(
          '$value',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? accent : Neon.dim,
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              NeonButton(
                  label: 'SOUNDS GOOD',
                  accent: Neon.magenta,
                  onPressed: () => repo.setFocus(day, suggestion)),
              NeonButton(
                  label: 'MY OWN',
                  accent: Neon.magenta,
                  filled: false,
                  onPressed: () => _chooseOwn(context, repo, day)),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Neon.dim),
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
          const Icon(Icons.check_circle, color: Neon.magenta),
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
          const Icon(Icons.bedtime_outlined, color: Neon.dim),
          const SizedBox(width: 12),
          const Expanded(child: Text('Skipped for today — no problem.')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Neon.magenta),
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              NeonButton(
                  label: 'DONE',
                  accent: Neon.magenta,
                  onPressed: () => repo.setFocusStatus(day, 'completed')),
              NeonButton(
                  label: 'CHANGE',
                  accent: Neon.magenta,
                  filled: false,
                  onPressed: () => _chooseOwn(context, repo, day)),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Neon.dim),
                onPressed: () => repo.setFocusStatus(day, 'skipped'),
                child: const Text('Skip today'),
              ),
            ],
          ),
        ],
      );
    }

    return NeonCard(
      accent: Neon.magenta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeonTitle("TODAY'S FOCUS", accent: Neon.magenta),
          const SizedBox(height: 12),
          body,
        ],
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
          NeonButton(
              label: 'SET',
              accent: Neon.magenta,
              onPressed: () => Navigator.pop(c, controller.text)),
        ],
      ),
    );
    if (text != null && text.trim().isNotEmpty) {
      await repo.setFocus(day, text.trim());
    }
  }
}
