import 'package:flutter_test/flutter_test.dart';
import 'package:life_app/features/nutrition/food_services.dart';

void main() {
  test('parses an Open Food Facts product into an editable estimate', () {
    final estimate = parseOpenFoodFactsResponse({
      'product': {
        'product_name': 'Greek yogurt',
        'brands': 'Example Dairy',
        'nutriments': {
          'energy-kcal_100g': 97,
          'proteins_100g': 9.1,
          'carbohydrates_100g': 4.2,
          'fat_100g': 4,
        },
      },
    });

    expect(estimate, isNotNull);
    expect(estimate!.name, 'Greek yogurt · Example Dairy · per 100 g');
    expect(estimate.calories, 97);
    expect(estimate.proteinG, 9.1);
    expect(estimate.carbsG, 4.2);
    expect(estimate.fatG, 4);
  });

  test(
    'prefers labelled serving nutrition when Open Food Facts provides it',
    () {
      final estimate = parseOpenFoodFactsResponse({
        'product': {
          'product_name': 'Protein bar',
          'serving_size': '45 g',
          'nutriments': {
            'energy-kcal_100g': 400,
            'proteins_100g': 30,
            'energy-kcal_serving': 180,
            'proteins_serving': 13.5,
            'carbohydrates_serving': 16,
            'fat_serving': 5,
          },
        },
      });

      expect(estimate, isNotNull);
      expect(estimate!.name, 'Protein bar · 45 g serving');
      expect(estimate.calories, 180);
      expect(estimate.proteinG, 13.5);
      expect(estimate.carbsG, 16);
      expect(estimate.fatG, 5);
    },
  );

  test('returns null when a product has no usable name', () {
    expect(parseOpenFoodFactsResponse({'product': {}}), isNull);
  });
}
