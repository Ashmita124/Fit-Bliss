import 'package:flutter/material.dart';
import 'package:fitbliss/data/models/nutrition_model.dart';
import 'package:fitbliss/screens/nutrition/nutrition_detail.dart';
import 'package:get/get.dart';
import 'package:fitbliss/data/services/get/nutrition.dart';
import 'package:intl/intl.dart';

class MealPlansScreen extends StatefulWidget {
  @override
  _MealPlansScreenState createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  final NutritionController _nutritionController = Get.find();
  late DateTime _currentDate;
  String _selectedMealType = 'Breakfast';
  int _selectedDayIndex =
      DateTime.now().weekday % 7; // 0-6 (Sunday=0, Saturday=6)
  late Map<DateTime, Map<String, NutritionModel?>> _mealPlan;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _initializeMealPlan();
  }

  void _initializeMealPlan() {
    _mealPlan = {};
    // Initialize 7 days starting from Sunday
    final sunday = _currentDate.subtract(
      Duration(days: _currentDate.weekday % 7),
    );
    for (int i = 0; i < 7; i++) {
      final day = sunday.add(Duration(days: i));
      _mealPlan[day] = {
        'Breakfast': null,
        'Lunch': null,
        'Dinner': null,
      };
    }
  }

  DateTime get _selectedDate {
    return _currentDate
        .subtract(Duration(days: _currentDate.weekday % 7))
        .add(Duration(days: _selectedDayIndex));
  }

  List<NutritionModel> _getAvailableMeals() {
    // Get all meals suitable for the selected meal type
    final suitableMeals = _nutritionController.nutritionItems
        .where((meal) => _isSuitableForMealType(meal, _selectedMealType))
        .toList();

    // Filter out meals already selected for this day
    final selectedMeals = _mealPlan[_selectedDate]!.values
        .whereType<NutritionModel>()
        .toList();
    final availableMeals = suitableMeals
        .where((meal) => !selectedMeals.contains(meal))
        .toList();

    // Shuffle and take 3
    availableMeals.shuffle();
    return availableMeals.length > 3
        ? availableMeals.sublist(0, 3)
        : availableMeals;
  }

  void _selectMeal(NutritionModel meal) {
    setState(() {
      _mealPlan[_selectedDate]![_selectedMealType] = meal;
    });
  }

  void _clearMeal() {
    setState(() {
      _mealPlan[_selectedDate]![_selectedMealType] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayMeals = _getAvailableMeals();
    final selectedMeal = _mealPlan[_selectedDate]![_selectedMealType];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          DateFormat('MMMM yyyy').format(_currentDate),
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Weekday Selector
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = _currentDate
                    .subtract(Duration(days: _currentDate.weekday % 7))
                    .add(Duration(days: index));
                final isSelected = index == _selectedDayIndex;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date), // Sun, Mon, etc.
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Color(0xffE91E63) : Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Meal Type Selector
          Container(
            height: 60,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMealTypeButton('Breakfast'),
                _buildMealTypeButton('Lunch'),
                _buildMealTypeButton('Dinner'),
              ],
            ),
          ),

          // Selected Meal Display
          if (selectedMeal != null) _buildSelectedMealCard(selectedMeal),

          // Meal Counter
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '${displayMeals.length} meals available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),

          // Meal Cards
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (var meal in displayMeals) _buildMealCard(meal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedMealCard(NutritionModel meal) {
    return Card(
      margin: EdgeInsets.all(16),
      color: Color(0xffE91E63).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Color(0xffE91E63),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                meal.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: Icon(Icons.food_bank, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected $_selectedMealType',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xffE91E63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.clear, color: Color(0xffE91E63)),
              onPressed: _clearMeal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeButton(String mealType) {
    final isSelected = _selectedMealType == mealType;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMealType = mealType;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xffE91E63) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          mealType,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(NutritionModel meal) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectMeal(meal),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  meal.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Center(child: Icon(Icons.food_bank)),
                  ),
                ),
              ),
              SizedBox(width: 16),

              // Meal Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Meal Description
                    Text(
                      meal.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Nutrition Info
                    Row(
                      children: [
                        _buildNutritionInfo('○ ${meal.calories} kcal'),
                        SizedBox(width: 16),
                        _buildNutritionInfo('○ 30 min'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
      ),
    );
  }

  bool _isSuitableForMealType(NutritionModel meal, String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return meal.category == NutritionCategory.carbohydrate ||
            meal.category == NutritionCategory.fruit ||
            meal.category == NutritionCategory.dairy ||
            meal.category == NutritionCategory.meal;
      case 'Lunch':
        return meal.category == NutritionCategory.meal ||
            meal.category == NutritionCategory.protein ||
            meal.category == NutritionCategory.vegetable;
      case 'Dinner':
        return meal.category == NutritionCategory.meal ||
            meal.category == NutritionCategory.protein ||
            meal.category == NutritionCategory.vegetable;
      default:
        return true;
    }
  }
}
