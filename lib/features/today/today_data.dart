import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/database/database_provider.dart';

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

int dayOfYear(DateTime d) =>
    d.difference(DateTime(d.year, 1, 1)).inDays + 1;

/// Deterministic rotation: same index for the whole day, changes daily.
int rotationIndex(DateTime date, int length) {
  if (length <= 0) return 0;
  return (dayOfYear(date) + date.year) % length;
}

class Ayah {
  const Ayah({
    required this.surah,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.tafsir,
    required this.source,
  });

  final String surah;
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String tafsir;
  final String source;
}

final ayahOfDayProvider = FutureProvider<Ayah>((ref) async {
  final raw = await rootBundle.loadString('assets/data/ayah_of_day.json');
  final data = json.decode(raw) as Map<String, dynamic>;
  final verses = data['verses'] as List;
  final v =
      verses[rotationIndex(DateTime.now(), verses.length)] as Map<String, dynamic>;
  return Ayah(
    surah: v['surah'] as String,
    surahNumber: v['surah_number'] as int,
    ayahNumber: v['ayah_number'] as int,
    text: v['text'] as String,
    tafsir: v['tafsir'] as String,
    source: data['source'] as String,
  );
});

const goodDeedSuggestions = [
  'صدقة ولو بسيطة',
  'صلة رحم',
  'مساعدة شخص',
  'قراءة شيء من القرآن',
  'الدعاء لشخص',
  'إدخال السرور على شخص',
];

const focusSuggestions = [
  'Take a 15-minute walk outside',
  'Drink water first thing and keep a bottle nearby',
  'Do 10 minutes of stretching or mobility',
  'Prepare one healthy meal at home',
  'Read for 15 minutes',
  'Go to bed 30 minutes earlier tonight',
  'Call or message someone you care about',
  'Spend 10 minutes tidying one small area',
  'Take 5 slow, deep breaths before starting work',
  'Step away from screens for one full hour',
];

class TodayRepository {
  TodayRepository(this.db);

  final AppDatabase db;

  // Good deeds
  Stream<List<GoodDeed>> watchDeeds(String day) =>
      (db.select(db.goodDeeds)..where((t) => t.day.equals(day))).watch();

  Future<int> addDeed(String day, String title) => db
      .into(db.goodDeeds)
      .insert(GoodDeedsCompanion.insert(day: day, title: title));

  Future<void> setDeedDone(int id, bool done) =>
      (db.update(db.goodDeeds)..where((t) => t.id.equals(id)))
          .write(GoodDeedsCompanion(done: Value(done)));

  Future<void> deleteDeed(int id) =>
      (db.delete(db.goodDeeds)..where((t) => t.id.equals(id))).go();

  // Check-in
  Stream<CheckIn?> watchCheckIn(String day) =>
      (db.select(db.checkIns)..where((t) => t.day.equals(day)))
          .watchSingleOrNull();

  Future<void> setCheckIn(String day,
      {int? mood, int? energy, int? physical}) async {
    final existing = await (db.select(db.checkIns)
          ..where((t) => t.day.equals(day)))
        .getSingleOrNull();
    if (existing == null) {
      await db.into(db.checkIns).insert(CheckInsCompanion.insert(
            day: day,
            mood: Value(mood),
            energy: Value(energy),
            physical: Value(physical),
          ));
    } else {
      await (db.update(db.checkIns)..where((t) => t.id.equals(existing.id)))
          .write(CheckInsCompanion(
        mood: mood != null ? Value(mood) : const Value.absent(),
        energy: energy != null ? Value(energy) : const Value.absent(),
        physical: physical != null ? Value(physical) : const Value.absent(),
      ));
    }
  }

  // Focus
  Stream<FocusEntry?> watchFocus(String day) =>
      (db.select(db.focusEntries)..where((t) => t.day.equals(day)))
          .watchSingleOrNull();

  Future<void> setFocus(String day, String title) async {
    final existing = await (db.select(db.focusEntries)
          ..where((t) => t.day.equals(day)))
        .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.focusEntries)
          .insert(FocusEntriesCompanion.insert(day: day, title: title));
    } else {
      await (db.update(db.focusEntries)
            ..where((t) => t.id.equals(existing.id)))
          .write(FocusEntriesCompanion(
              title: Value(title), status: const Value('pending')));
    }
  }

  Future<void> setFocusStatus(String day, String status) async {
    await (db.update(db.focusEntries)..where((t) => t.day.equals(day)))
        .write(FocusEntriesCompanion(status: Value(status)));
  }
}

final todayRepositoryProvider =
    Provider<TodayRepository>((ref) => TodayRepository(ref.watch(databaseProvider)));

final todayDeedsProvider = StreamProvider<List<GoodDeed>>((ref) =>
    ref.watch(todayRepositoryProvider).watchDeeds(dayKey(DateTime.now())));

final todayCheckInProvider = StreamProvider<CheckIn?>((ref) =>
    ref.watch(todayRepositoryProvider).watchCheckIn(dayKey(DateTime.now())));

final todayFocusProvider = StreamProvider<FocusEntry?>((ref) =>
    ref.watch(todayRepositoryProvider).watchFocus(dayKey(DateTime.now())));
