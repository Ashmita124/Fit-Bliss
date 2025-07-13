class NutritionModel {
  final int id;
  final String name;
  final String description;
  final int calories;
  final String protein;
  final String carbs;
  final String fats;
  final NutritionCategory category;
  final String image;
  final List<String> preparation;
  final List<String> benefits;

  NutritionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.category,
    required this.image,
    required this.preparation,
    required this.benefits,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      calories: json['calories'] as int,
      protein: json['protein'] as String,
      carbs: json['carbs'] as String,
      fats: json['fats'] as String,
      category: NutritionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => NutritionCategory.carbohydrate,
      ),
      image: json['image'] as String,
      preparation: List<String>.from(json['preparation'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
    );
  }
}

enum NutritionCategory {
  carbohydrate,
  protein,
  fat,
  vegetable,
  fruit,
  dairy,
  snack,
  beverage,
  supplement,
  meal,
}

extension NutritionCategoryExtension on NutritionCategory {
  String get displayName {
    switch (this) {
      case NutritionCategory.carbohydrate:
        return "Carbohydrates";
      case NutritionCategory.protein:
        return "Proteins";
      case NutritionCategory.fat:
        return "Fats";
      case NutritionCategory.vegetable:
        return "Vegetables";
      case NutritionCategory.fruit:
        return "Fruits";
      case NutritionCategory.dairy:
        return "Dairy";
      case NutritionCategory.snack:
        return "Snacks";
      case NutritionCategory.beverage:
        return "Beverages";
      case NutritionCategory.supplement:
        return "Supplements";
      case NutritionCategory.meal:
        return "Meals";
    }
  }
}
