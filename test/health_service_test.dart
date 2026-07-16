import 'package:flutter_test/flutter_test.dart';
import 'package:life_app/core/health/health_service.dart';

void main() {
  test('summarizes average heart rate and time in target range', () {
    final start = DateTime(2026, 7, 16, 8);
    final summary = summarizeHeartRate([
      HeartRateSample(bpm: 130, at: start),
      HeartRateSample(bpm: 145, at: start.add(const Duration(seconds: 60))),
      HeartRateSample(bpm: 165, at: start.add(const Duration(seconds: 120))),
    ], lowBpm: 120, highBpm: 150);

    expect(summary.averageBpm, 147);
    expect(summary.inZoneMin, 2);
  });
}
