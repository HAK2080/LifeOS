import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HealthConnectionAvailability { available, updateRequired, unavailable }

class HealthConnectionSnapshot {
  const HealthConnectionSnapshot({
    required this.availability,
    required this.permissionsGranted,
    required this.syncEnabled,
    this.lastSync,
    this.detail,
  });

  final HealthConnectionAvailability availability;
  final bool permissionsGranted;
  final bool syncEnabled;
  final DateTime? lastSync;
  final String? detail;

  HealthConnectionSnapshot copyWith({
    HealthConnectionAvailability? availability,
    bool? permissionsGranted,
    bool? syncEnabled,
    DateTime? lastSync,
    String? detail,
  }) {
    return HealthConnectionSnapshot(
      availability: availability ?? this.availability,
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      lastSync: lastSync ?? this.lastSync,
      detail: detail ?? this.detail,
    );
  }
}

class HeartRateSample {
  const HeartRateSample({required this.bpm, required this.at});

  final int bpm;
  final DateTime at;
}

class HeartRateSummary {
  const HeartRateSummary({required this.averageBpm, required this.inZoneMin});

  final int averageBpm;
  final int inZoneMin;
}

HeartRateSummary summarizeHeartRate(
  List<HeartRateSample> samples, {
  required int lowBpm,
  required int highBpm,
}) {
  if (samples.isEmpty) {
    return const HeartRateSummary(averageBpm: 0, inZoneMin: 0);
  }
  final ordered = [...samples]..sort((a, b) => a.at.compareTo(b.at));
  final average =
      (ordered.map((s) => s.bpm).reduce((a, b) => a + b) / ordered.length)
          .round();
  var inZoneSeconds = 0;
  for (var i = 0; i < ordered.length - 1; i++) {
    final seconds = ordered[i + 1].at.difference(ordered[i].at).inSeconds;
    if (seconds > 0 &&
        seconds <= 120 &&
        ordered[i].bpm >= lowBpm &&
        ordered[i].bpm <= highBpm) {
      inZoneSeconds += seconds;
    }
  }
  return HeartRateSummary(
    averageBpm: average,
    inZoneMin: (inZoneSeconds / 60).round(),
  );
}

abstract interface class HealthGateway {
  Future<bool> requestReadPermissions();
  Future<HealthConnectionSnapshot> inspectConnection();
  Future<void> revokePermissions();
  Future<bool> openSettings();
  Future<int?> readTodaySteps();
  Future<List<HeartRateSample>> readHeartRate(DateTime start, DateTime end);
}

/// Android Health Connect adapter. The interface keeps training screens
/// independent from the provider and preserves manual entry when unavailable.
class HealthConnectGateway implements HealthGateway {
  HealthConnectGateway() : _health = Health();

  final Health _health;
  bool _configured = false;
  static const _settingsChannel = MethodChannel('lifeos/health_connect');
  static const _types = [HealthDataType.STEPS, HealthDataType.HEART_RATE];
  static const _readPermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<bool> requestReadPermissions() async {
    await _configure();
    return _health.requestAuthorization(_types, permissions: _readPermissions);
  }

  @override
  Future<HealthConnectionSnapshot> inspectConnection() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const HealthConnectionSnapshot(
        availability: HealthConnectionAvailability.unavailable,
        permissionsGranted: false,
        syncEnabled: false,
        detail: 'Health Connect is available only in the Android app.',
      );
    }
    await _configure();
    final sdkStatus = await _health.getHealthConnectSdkStatus();
    if (sdkStatus ==
        HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
      return const HealthConnectionSnapshot(
        availability: HealthConnectionAvailability.updateRequired,
        permissionsGranted: false,
        syncEnabled: false,
        detail: 'Health Connect needs to be installed or updated.',
      );
    }
    if (sdkStatus != HealthConnectSdkStatus.sdkAvailable) {
      return const HealthConnectionSnapshot(
        availability: HealthConnectionAvailability.unavailable,
        permissionsGranted: false,
        syncEnabled: false,
        detail: 'Health Connect is unavailable on this device.',
      );
    }
    final granted = await _health.hasPermissions(
      _types,
      permissions: _readPermissions,
    );
    return HealthConnectionSnapshot(
      availability: HealthConnectionAvailability.available,
      permissionsGranted: granted == true,
      syncEnabled: false,
    );
  }

  @override
  Future<void> revokePermissions() async {
    await _configure();
    await _health.revokePermissions();
  }

  @override
  Future<bool> openSettings() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    return await _settingsChannel.invokeMethod<bool>('openSettings') ?? false;
  }

  @override
  Future<int?> readTodaySteps() async {
    await _configure();
    final now = DateTime.now();
    return _health.getTotalStepsInInterval(
      DateTime(now.year, now.month, now.day),
      now,
    );
  }

  @override
  Future<List<HeartRateSample>> readHeartRate(
    DateTime start,
    DateTime end,
  ) async {
    await _configure();
    final points = await _health.getHealthDataFromTypes(
      types: [HealthDataType.HEART_RATE],
      startTime: start,
      endTime: end,
    );
    return [
      for (final point in _health.removeDuplicates(points))
        if (point.value case NumericHealthValue value)
          HeartRateSample(bpm: value.numericValue.round(), at: point.dateTo),
    ];
  }
}

final healthGatewayProvider = Provider<HealthGateway>((ref) {
  return HealthConnectGateway();
});

final healthConnectionProvider =
    AsyncNotifierProvider<HealthConnectionNotifier, HealthConnectionSnapshot>(
      HealthConnectionNotifier.new,
    );

class HealthConnectionNotifier extends AsyncNotifier<HealthConnectionSnapshot> {
  static const _syncEnabledKey = 'health_connect_sync_enabled';
  static const _lastSyncKey = 'health_connect_last_sync_ms';

  @override
  Future<HealthConnectionSnapshot> build() => _read();

  Future<HealthConnectionSnapshot> _read() async {
    final preferences = await SharedPreferences.getInstance();
    final syncEnabled = preferences.getBool(_syncEnabledKey) ?? true;
    final lastSyncMs = preferences.getInt(_lastSyncKey);
    try {
      final connection = await ref
          .read(healthGatewayProvider)
          .inspectConnection();
      return connection.copyWith(
        syncEnabled: syncEnabled,
        lastSync: lastSyncMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(lastSyncMs),
      );
    } catch (error) {
      return HealthConnectionSnapshot(
        availability: HealthConnectionAvailability.unavailable,
        permissionsGranted: false,
        syncEnabled: syncEnabled,
        lastSync: lastSyncMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(lastSyncMs),
        detail: 'Could not inspect Health Connect: $error',
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _read());
  }

  Future<void> setSyncEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_syncEnabledKey, enabled);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(syncEnabled: enabled));
    }
  }

  Future<bool> requestAccess() async {
    try {
      final granted = await ref
          .read(healthGatewayProvider)
          .requestReadPermissions();
      await refresh();
      return granted;
    } catch (_) {
      await refresh();
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await ref.read(healthGatewayProvider).revokePermissions();
    } finally {
      await setSyncEnabled(false);
      await refresh();
    }
  }

  Future<bool> openSettings() => ref.read(healthGatewayProvider).openSettings();

  Future<void> recordSuccessfulSync() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
      _lastSyncKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    await refresh();
  }
}

final healthStepsProvider = AsyncNotifierProvider<HealthStepsNotifier, int?>(
  HealthStepsNotifier.new,
);

class HealthStepsNotifier extends AsyncNotifier<int?> {
  @override
  Future<int?> build() async => null;

  Future<bool> sync() async {
    state = const AsyncLoading();
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!(preferences.getBool('health_connect_sync_enabled') ?? true)) {
        state = const AsyncData(null);
        return false;
      }
      final gateway = ref.read(healthGatewayProvider);
      if (!await gateway.requestReadPermissions()) {
        state = const AsyncData(null);
        return false;
      }
      state = AsyncData(await gateway.readTodaySteps());
      await ref.read(healthConnectionProvider.notifier).recordSuccessfulSync();
      return true;
    } catch (_) {
      state = const AsyncData(null);
      return false;
    }
  }
}
