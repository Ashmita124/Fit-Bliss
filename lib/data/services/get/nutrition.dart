import 'package:fitbliss/data/nutition.dart';
import 'package:get/get.dart';
import 'package:fitbliss/data/models/nutrition_model.dart';

class NutritionController extends GetxController {
  List<NutritionModel> _nutritionItems = [];
  bool _isLoaded = false;

  List<NutritionModel> get nutritionItems => _nutritionItems;
  bool get isLoaded => _isLoaded;

  Future<void> loadNutrition() async {
    if (_isLoaded) return;

    _nutritionItems = [
      for (final nutrition in nutritionData) NutritionModel.fromJson(nutrition),
    ];

    _isLoaded = true;
    update();
  }

  // Get items by category
  List<NutritionModel> getByCategory(NutritionCategory category) {
    return _nutritionItems.where((item) => item.category == category).toList();
  }
}

final NutritionController nutritionController = Get.put(NutritionController());
