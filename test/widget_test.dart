import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:life_app/core/database/database.dart';
import 'package:life_app/features/today/today_data.dart';
import 'package:life_app/main.dart';

void main() {
  testWidgets('app opens on Today with all five tabs', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        // Ayah loads from the real bundled asset — only DB streams are stubbed.
        todayDeedsProvider.overrideWith((ref) => Stream.value(<GoodDeed>[])),
        todayCheckInProvider.overrideWith((ref) => Stream.value(null)),
        todayFocusProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: const LifeApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Training'), findsOneWidget);
    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
    // "Today" appears in both the tab bar and the app bar → opened on Today.
    expect(find.text('Today'), findsNWidgets(2));
    // Today content is visible, including the real ayah from the asset.
    expect(find.text('آية اليوم'), findsOneWidget);
    expect(find.text('عمل الخير اليوم'), findsOneWidget);
    expect(find.textContaining('﴿'), findsOneWidget); // surah reference line
  });
}
