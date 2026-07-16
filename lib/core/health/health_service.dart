import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

class HeartRateSample {
  const HeartRateSample({required this.bpm, required this.at});

  final int bpm;
  final DateTime at;
}

abstract interface class HealthGateway {
  Future<bool> requestReadPermissions();
  Future<int?> readTodaySteps();
  Future<List<HeartRateSample>> readHeartRate(
      DateTime start, DateTime end);
}

/// Android Health Connect adapter. The interface keeps training screens
/// independent from the provider and preserves manual entry when unavailable.
class HealthConnectGateway implements HealthGateway {
  HealthConnectGateway() : _health = Health();

  final Health _health;
  bool _configured = false;

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<bool> requestReadPermissions() async {
    await _configure();
    return _health.requestAuthorization(
      [HealthDataType.STEPS, HealthDataType.HEART_RATE],
      permissions: [HealthDataAccess.READ, HealthDataAccess.READ],
    );
  }

  @override
  Future<int?> readTodaySteps() async {
    await _configure();
    final now = DateTime.now();
    return _health.getTotalStepsInInterval(
        DateTime(now.year, now.month, now.day), now);
  }

  @override
  Future<List<HeartRateSample>> readHeartRate(
      DateTime start, DateTime end) async {
    await _configure();
    final points = await _health.getHealthDataFromTypes(
      types: [HealthDataType.HEART_RATE],
      startTime: start,
      endTime: end,
    );
    return [
      for (final point in _health.removeDuplicates(points))
        if (point.value case NumericHealthValue value)
          HeartRateSample(
              bpm: value.numericValue.round(), at: point.dateTo),
    ];
  }
}

final healthGatewayProvider = Provider<HealthGateway>((ref) {
  return HealthConnectGateway();
});

final healthStepsProvider =
    AsyncNotifierProvider<HealthStepsNotifier, int?>(HealthStepsNotifier.new);

class HealthStepsNotifier extends AsyncNotifier<int?> {
  @override
  Future<int?> build() async => null;

  Future<bool> sync() async {
    state = const AsyncLoading();
    try {
      final gateway = ref.read(healthGatewayProvider);
      if (!await gateway.requestReadPermissions()) {
        state = const AsyncData(null);
        return false;
      }
      state = AsyncData(await gateway.readTodaySteps());
      return true;
    } catch (_) {
      state = const AsyncData(null);
      return false;
    }
  }
}
