import 'package:flutter_test/flutter_test.dart';
import 'package:life_app/features/nutrition/food_services.dart';

void main() {
  test('manual-only services keep optional AI paths offline and editable', () async {
    expect(await const ManualOnlyFoodRecognitionService().estimateFromImage('photo.jpg'), isNull);
    expect(await const ManualOnlyBarcodeProductService().lookup('123'), isNull);
  });
}
