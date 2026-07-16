import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/style.dart';
import '../../core/notifications/notification_service.dart';

/// Global default rest between sets, editable in Settings (seconds).
final defaultRestProvider =
    AsyncNotifierProvider<DefaultRestNotifier, int>(DefaultRestNotifier.new);

class DefaultRestNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('rest_set_sec') ?? 120;
  }

  Future<void> set(int seconds) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('rest_set_sec', seconds);
    state = AsyncData(seconds);
  }
}

class RestTimerState {
  const RestTimerState(
      {this.total = 0, this.remaining = 0, this.running = false});

  final int total;
  final int remaining;
  final bool running;

  bool get active => remaining > 0;
}

class RestTimerController extends Notifier<RestTimerState> {
  Timer? _ticker;

  @override
  RestTimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const RestTimerState();
  }

  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  void start(int seconds) {
    if (seconds <= 0) return;
    _ticker?.cancel();
    state = RestTimerState(total: seconds, remaining: seconds, running: true);
    _notifications
        .scheduleRestDone(DateTime.now().add(Duration(seconds: seconds)));
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!state.running) return;
    final next = state.remaining - 1;
    if (next <= 0) {
      _ticker?.cancel();
      state = const RestTimerState();
    } else {
      state = RestTimerState(
          total: state.total, remaining: next, running: true);
    }
  }

  void pause() {
    state = RestTimerState(
        total: state.total, remaining: state.remaining, running: false);
    _notifications.cancelRestDone();
  }

  void resume() {
    state = RestTimerState(
        total: state.total, remaining: state.remaining, running: true);
    _notifications.scheduleRestDone(
        DateTime.now().add(Duration(seconds: state.remaining)));
  }

  void addTime(int seconds) {
    if (!state.active) return;
    final next = state.remaining + seconds;
    state =
        RestTimerState(total: state.total + seconds, remaining: next, running: state.running);
    if (state.running) {
      _notifications
          .scheduleRestDone(DateTime.now().add(Duration(seconds: next)));
    }
  }

  void skip() {
    _ticker?.cancel();
    _notifications.cancelRestDone();
    state = const RestTimerState();
  }
}

final restTimerProvider =
    NotifierProvider<RestTimerController, RestTimerState>(
        RestTimerController.new);

/// Sticky bar shown above the bottom of the session screen while resting.
class RestTimerBar extends ConsumerWidget {
  const RestTimerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(restTimerProvider);
    if (!timer.active) return const SizedBox.shrink();
    final controller = ref.read(restTimerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final m = (timer.remaining ~/ 60).toString();
    final s = (timer.remaining % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: timer.total == 0 ? 0 : timer.remaining / timer.total,
                strokeWidth: 3,
                backgroundColor: scheme.outline,
              ),
            ),
            const SizedBox(width: 12),
            Text('$m:$s',
                style: const TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('rest', style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            IconButton(
              tooltip: '+30s',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => controller.addTime(30),
            ),
            IconButton(
              tooltip: timer.running ? 'Pause' : 'Resume',
              icon: Icon(timer.running
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline),
              onPressed: () =>
                  timer.running ? controller.pause() : controller.resume(),
            ),
            IconButton(
              tooltip: 'Skip',
              icon: const Icon(Icons.skip_next, color: AppColors.accent),
              onPressed: controller.skip,
            ),
          ],
        ),
      ),
    );
  }
}
