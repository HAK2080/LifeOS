import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodEstimate {
  const FoodEstimate({required this.name, this.calories, this.proteinG, this.carbsG, this.fatG});

  final String name;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
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

final foodRecognitionServiceProvider =
    Provider<FoodRecognitionService>((ref) => const ManualOnlyFoodRecognitionService());
final barcodeProductServiceProvider =
    Provider<BarcodeProductService>((ref) => const ManualOnlyBarcodeProductService());
