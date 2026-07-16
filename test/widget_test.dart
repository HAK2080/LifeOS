import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:life_app/core/database/database.dart';
import 'package:life_app/features/today/today_data.dart';
import 'package:life_app/main.dart';

void main() {
  testWidgets('app opens on Today with all five tabs', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        todayDeedsProvider.overrideWith((ref) => Stream.value(<GoodDeed>[])),
        todayFocusProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: const LifeApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Training'), findsOneWidget);
    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('Growth'), findsOneWidget);
    expect(find.text('Today'), findsNWidgets(2));
  });
}
