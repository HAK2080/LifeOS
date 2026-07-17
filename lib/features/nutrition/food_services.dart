import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/build_info.dart';

class FoodEstimate {
  const FoodEstimate({
    required this.name,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });

  final String name;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;

  Map<String, dynamic> toJson() => {
    'name': name,
    'calories': calories,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
  };

  factory FoodEstimate.fromJson(Map<String, dynamic> json) => FoodEstimate(
    name: json['name'] as String,
    calories: (json['calories'] as num?)?.toDouble(),
    proteinG: (json['proteinG'] as num?)?.toDouble(),
    carbsG: (json['carbsG'] as num?)?.toDouble(),
    fatG: (json['fatG'] as num?)?.toDouble(),
  );
}

/// Optional provider boundary. Manual logging remains the default and never
/// requires network access or an AI account.
abstract interface class FoodRecognitionService {
  Future<FoodEstimate?> estimateFromImage(String path);
}

abstract interface class BarcodeProductService {
  Future<FoodEstimate?> lookup(String barcode);
}

class ManualOnlyFoodRecognitionService implements FoodRecognitionService {
  const ManualOnlyFoodRecognitionService();

  @override
  Future<FoodEstimate?> estimateFromImage(String path) async => null;
}

class ManualOnlyBarcodeProductService implements BarcodeProductService {
  const ManualOnlyBarcodeProductService();

  @override
  Future<FoodEstimate?> lookup(String barcode) async => null;
}

/// Optional online barcode lookup backed by Open Food Facts.
///
/// A lookup happens only after the user scans a barcode. Successful products
/// are cached on-device so the same barcode remains available offline. A miss
/// or network failure returns null and the manual editor remains available.
class OpenFoodFactsBarcodeProductService implements BarcodeProductService {
  OpenFoodFactsBarcodeProductService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<FoodEstimate?> lookup(String barcode) async {
    final normalized = barcode.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.length < 8 || normalized.length > 14) return null;

    final preferences = await SharedPreferences.getInstance();
    final cacheKey = 'open_food_facts_$normalized';
    final cached = preferences.getString(cacheKey);
    if (cached != null) {
      try {
        return FoodEstimate.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
      } catch (_) {
        await preferences.remove(cacheKey);
      }
    }

    try {
      final uri = Uri.https(
        'world.openfoodfacts.org',
        '/api/v3/product/$normalized',
        {'fields': 'code,product_name,brands,serving_size,nutriments'},
      );
      final response = await _client
          .get(
            uri,
            headers: kIsWeb
                ? const {}
                : const {
                    'User-Agent':
                        'LifeOS/${AppBuildInfo.version} (https://github.com/HAK2080/LifeOS)',
                  },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final estimate = parseOpenFoodFactsResponse(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      if (estimate != null) {
        await preferences.setString(cacheKey, jsonEncode(estimate.toJson()));
      }
      return estimate;
    } catch (_) {
      return null;
    }
  }
}

FoodEstimate? parseOpenFoodFactsResponse(Map<String, dynamic> response) {
  final rawProduct = response['product'];
  if (rawProduct is! Map) return null;
  final product = Map<String, dynamic>.from(rawProduct);
  final productName = (product['product_name'] as String?)?.trim();
  final brands = (product['brands'] as String?)?.trim();
  final name = [
    if (productName != null && productName.isNotEmpty) productName,
    if (brands != null && brands.isNotEmpty && brands != productName) brands,
  ].join(' · ');
  if (name.isEmpty) return null;

  final rawNutrients = product['nutriments'];
  final nutrients = rawNutrients is Map
      ? Map<String, dynamic>.from(rawNutrients)
      : const <String, dynamic>{};
  final servingSize = (product['serving_size'] as String?)?.trim();
  final servingCalories = _nutrient(nutrients, 'energy-kcal_serving');
  final useServing = servingCalories != null;
  final basis = useServing
      ? (servingSize == null || servingSize.isEmpty
            ? 'per serving'
            : '$servingSize serving')
      : 'per 100 g';
  return FoodEstimate(
    name: '$name · $basis',
    calories: useServing
        ? servingCalories
        : _nutrient(nutrients, 'energy-kcal_100g'),
    proteinG: _nutrient(
      nutrients,
      useServing ? 'proteins_serving' : 'proteins_100g',
    ),
    carbsG: _nutrient(
      nutrients,
      useServing ? 'carbohydrates_serving' : 'carbohydrates_100g',
    ),
    fatG: _nutrient(nutrients, useServing ? 'fat_serving' : 'fat_100g'),
  );
}

double? _nutrient(Map<String, dynamic> nutrients, String key) {
  final value = nutrients[key];
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

final foodRecognitionServiceProvider = Provider<FoodRecognitionService>(
  (ref) => const ManualOnlyFoodRecognitionService(),
);
final barcodeProductServiceProvider = Provider<BarcodeProductService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return OpenFoodFactsBarcodeProductService(client: client);
});
