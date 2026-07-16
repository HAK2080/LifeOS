import 'dart:convert';

class WellnessSourceSpec {
  const WellnessSourceSpec({
    required this.id,
    required this.title,
    required this.publisher,
    required this.url,
  });

  factory WellnessSourceSpec.fromJson(Map<String, dynamic> json) {
    return WellnessSourceSpec(
      id: json['id'] as String,
      title: json['title'] as String,
      publisher: json['publisher'] as String,
      url: json['url'] as String,
    );
  }

  final String id;
  final String title;
  final String publisher;
  final String url;
}

class WellnessProtocolSpec {
  const WellnessProtocolSpec({
    required this.id,
    required this.version,
    required this.category,
    required this.title,
    required this.purpose,
    required this.instructions,
    required this.minimumVersion,
    required this.standardVersion,
    required this.frequency,
    required this.durationMinutes,
    required this.bestTime,
    required this.evidenceLevel,
    required this.safetyNotes,
    required this.reviewPeriodDays,
    required this.sources,
  });

  factory WellnessProtocolSpec.fromJson(Map<String, dynamic> json) {
    return WellnessProtocolSpec(
      id: json['id'] as String,
      version: json['version'] as int,
      category: json['category'] as String,
      title: json['title'] as String,
      purpose: json['purpose'] as String,
      instructions: json['instructions'] as String,
      minimumVersion: json['minimum_version'] as String,
      standardVersion: json['standard_version'] as String,
      frequency: json['frequency'] as String,
      durationMinutes: json['duration_minutes'] as int?,
      bestTime: json['best_time'] as String,
      evidenceLevel: json['evidence_level'] as String,
      safetyNotes: json['safety_notes'] as String,
      reviewPeriodDays: json['review_period_days'] as int,
      sources: (json['sources'] as List)
          .cast<Map<String, dynamic>>()
          .map(WellnessSourceSpec.fromJson)
          .toList(growable: false),
    );
  }

  static List<WellnessProtocolSpec> parseSeed(String raw) {
    final root = json.decode(raw) as Map<String, dynamic>;
    return (root['protocols'] as List)
        .cast<Map<String, dynamic>>()
        .map(WellnessProtocolSpec.fromJson)
        .toList(growable: false);
  }

  final String id;
  final int version;
  final String category;
  final String title;
  final String purpose;
  final String instructions;
  final String minimumVersion;
  final String standardVersion;
  final String frequency;
  final int? durationMinutes;
  final String bestTime;
  final String evidenceLevel;
  final String safetyNotes;
  final int reviewPeriodDays;
  final List<WellnessSourceSpec> sources;
}
