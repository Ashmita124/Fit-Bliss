import 'package:fitbliss/screens/onboarding/goal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fitbliss/data/models/nutrition_model.dart';
import 'package:fitbliss/data/models/exercise_model.dart';
import 'package:fitbliss/data/models/user_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProgressDashboard extends StatefulWidget {
  const ProgressDashboard({super.key});

  @override
  State<ProgressDashboard> createState() => _ProgressDashboardState();
}

class _ProgressDashboardState extends State<ProgressDashboard> {
  String selectedPeriod = 'Today';
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = UserModel(
      id: 'user123',
      name: 'Alex Johnson',
      email: 'alex@example.com',
      phone: '123-456-7890',
      age: '28',
      weight: '75kg',
      level: 'Intermediate',
      goal: 'Weight Loss',
    );
  }

  // Dummy data for demonstration
  Map<String, Map<String, dynamic>> get dummyData {
    return {
      'Today': {
        'calories': 2100,
        'protein': 120,
        'carbs': 180,
        'fats': 70,
        'exerciseCalories': 399,
        'heartRate': 115,
        'steps': 2265,
        'sleep': 8.5,
      },
      'Week': {
        'calories': 14700,
        'protein': 840,
        'carbs': 1260,
        'fats': 490,
        'exerciseCalories': 2793,
        'heartRate': 118,
        'steps': 15855,
        'sleep': 59.5,
      },
      'Month': {
        'calories': 63000,
        'protein': 3600,
        'carbs': 5400,
        'fats': 2100,
        'exerciseCalories': 11970,
        'heartRate': 112,
        'steps': 67950,
        'sleep': 255,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final data = dummyData[selectedPeriod]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'PROGRESS DASHBOARD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xffE91E63),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Today', 'Week', 'Month'].map((period) {
                  return ChoiceChip(
                    label: Text(
                      period,
                      style: TextStyle(
                        color: selectedPeriod == period
                            ? Colors.white
                            : const Color(0xffE91E63),
                      ),
                    ),
                    selected: selectedPeriod == period,
                    onSelected: (selected) {
                      setState(() {
                        selectedPeriod = period;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xffE91E63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xffE91E63)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // User info
            // _buildUserInfo(),
            // const SizedBox(height: 16),

            // Nutrition summary
            _buildSectionTitle('Nutrition Summary'),
            const SizedBox(height: 8),
            _buildNutritionSummary(data),
            const SizedBox(height: 16),

            // Activity summary
            _buildSectionTitle('Activity Summary'),
            const SizedBox(height: 8),
            _buildActivitySummary(data),
            const SizedBox(height: 16),

            // Progress charts
            _buildSectionTitle('Progress Overview'),
            const SizedBox(height: 8),
            _buildProgressCharts(),
            const SizedBox(height: 16),

            // Recent nutrition
            _buildSectionTitle('Recent Nutrition'),
            const SizedBox(height: 8),
            _buildRecentNutrition(),
            const SizedBox(height: 16),

            // Recent exercises
            _buildSectionTitle('Recent Exercises'),
            const SizedBox(height: 8),
            _buildRecentExercises(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNutritionSummary(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildMetricCard(
            title: 'Calories',
            value: '${data['calories']}',
            unit: 'kcal',
            icon: Icons.local_fire_department,
            color: const Color(0xffE91E63),
          ),
          _buildMetricCard(
            title: 'Protein',
            value: '${data['protein']}',
            unit: 'g',
            icon: Icons.fitness_center,
            color: const Color(0xFF4CAF50),
          ),
          _buildMetricCard(
            title: 'Carbs',
            value: '${data['carbs']}',
            unit: 'g',
            icon: Icons.grain,
            color: const Color(0xFFFFC107),
          ),
          _buildMetricCard(
            title: 'Fats',
            value: '${data['fats']}',
            unit: 'g',
            icon: Icons.oil_barrel,
            color: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySummary(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildMetricCard(
            title: 'Calories Burned',
            value: '${data['exerciseCalories']}',
            unit: 'kcal',
            icon: Icons.local_fire_department,
            color: const Color(0xFFFF9800),
          ),
          _buildMetricCard(
            title: 'Heart Rate',
            value: '${data['heartRate']}',
            unit: 'bpm',
            icon: Icons.favorite,
            color: const Color(0xffE91E63),
          ),
          _buildMetricCard(
            title: 'Steps',
            value: '${data['steps']}',
            unit: '',
            icon: Icons.directions_walk,
            color: const Color(0xFF2196F3),
          ),
          _buildMetricCard(
            title: 'Sleep',
            value: '${data['sleep']}',
            unit: 'hours',
            icon: Icons.bedtime,
            color: const Color(0xFF9C27B0),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCharts() {
    // Dummy chart data
    final caloriesData = [
      {'day': 'Mon', 'consumed': 2100, 'burned': 400},
      {'day': 'Tue', 'consumed': 2200, 'burned': 420},
      {'day': 'Wed', 'consumed': 1900, 'burned': 450},
      {'day': 'Thu', 'consumed': 2300, 'burned': 380},
      {'day': 'Fri', 'consumed': 2000, 'burned': 500},
      {'day': 'Sat', 'consumed': 2500, 'burned': 350},
      {'day': 'Sun', 'consumed': 1800, 'burned': 400},
    ];

    final macroData = [
      {'day': 'Mon', 'protein': 120, 'carbs': 180, 'fats': 70},
      {'day': 'Tue', 'protein': 130, 'carbs': 190, 'fats': 75},
      {'day': 'Wed', 'protein': 110, 'carbs': 160, 'fats': 65},
      {'day': 'Thu', 'protein': 140, 'carbs': 200, 'fats': 80},
      {'day': 'Fri', 'protein': 125, 'carbs': 170, 'fats': 60},
      {'day': 'Sat', 'protein': 150, 'carbs': 220, 'fats': 85},
      {'day': 'Sun', 'protein': 100, 'carbs': 150, 'fats': 55},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(color: Colors.black54),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: Colors.black54),
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: Colors.grey,
                ),
              ),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.top,
                textStyle: const TextStyle(color: Colors.black87),
              ),
              series: <CartesianSeries>[
                ColumnSeries<Map<String, dynamic>, String>(
                  name: 'Consumed',
                  dataSource: caloriesData,
                  xValueMapper: (data, _) => data['day'],
                  yValueMapper: (data, _) => data['consumed'],
                  color: const Color(0xffE91E63),
                ),
                ColumnSeries<Map<String, dynamic>, String>(
                  name: 'Burned',
                  dataSource: caloriesData,
                  xValueMapper: (data, _) => data['day'],
                  yValueMapper: (data, _) => data['burned'],
                  color: const Color(0xFFFF9800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(color: Colors.black54),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(color: Colors.black54),
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: Colors.grey,
                ),
              ),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.top,
                textStyle: const TextStyle(color: Colors.black87),
              ),
              series: <CartesianSeries>[
                LineSeries<Map<String, dynamic>, String>(
                  name: 'Protein',
                  dataSource: macroData,
                  xValueMapper: (data, _) => data['day'],
                  yValueMapper: (data, _) => data['protein'],
                  color: const Color(0xFF4CAF50),
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
                LineSeries<Map<String, dynamic>, String>(
                  name: 'Carbs',
                  dataSource: macroData,
                  xValueMapper: (data, _) => data['day'],
                  yValueMapper: (data, _) => data['carbs'],
                  color: const Color(0xFFFFC107),
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
                LineSeries<Map<String, dynamic>, String>(
                  name: 'Fats',
                  dataSource: macroData,
                  xValueMapper: (data, _) => data['day'],
                  yValueMapper: (data, _) => data['fats'],
                  color: const Color(0xFF2196F3),
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNutrition() {
    // Dummy nutrition items
    final nutritionItems = [
      NutritionModel(
        id: 1,
        name: 'Avocado Toast',
        description: 'Healthy breakfast',
        calories: 320,
        protein: '8',
        carbs: '35',
        fats: '18',
        category: NutritionCategory.meal,
        image: '',
        preparation: [],
        benefits: [],
      ),
      NutritionModel(
        id: 2,
        name: 'Grilled Chicken Salad',
        description: 'High protein meal',
        calories: 420,
        protein: '35',
        carbs: '12',
        fats: '22',
        category: NutritionCategory.meal,
        image: '',
        preparation: [],
        benefits: [],
      ),
      NutritionModel(
        id: 3,
        name: 'Protein Shake',
        description: 'Post-workout recovery',
        calories: 180,
        protein: '25',
        carbs: '10',
        fats: '5',
        category: NutritionCategory.supplement,
        image: '',
        preparation: [],
        benefits: [],
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: nutritionItems.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fastfood, color: Colors.grey),
              ),
              title: Text(
                item.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    item.category.displayName,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildNutritionTag('${item.calories} kcal'),
                      const SizedBox(width: 8),
                      _buildNutritionTag('P: ${item.protein}g'),
                      const SizedBox(width: 8),
                      _buildNutritionTag('C: ${item.carbs}g'),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.calories.toString(),
                    style: const TextStyle(
                      color: Color(0xffE91E63),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'kcal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNutritionTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildRecentExercises() {
    // Dummy exercise items
    final exercises = [
      ExerciseModel(
        id: 1,
        name: 'Morning Yoga',
        description: 'Relaxing yoga session',
        difficulty: 'Beginner',
        category: Goal.improve_fitness,
        image: '',
        duration: '30',
        kcal: 180,
        reps: 0,
        instructions: [],
        benefits: [],
      ),
      ExerciseModel(
        id: 2,
        name: 'HIIT Workout',
        description: 'High intensity training',
        difficulty: 'Advanced',
        category: Goal.weight_loss,
        image: '',
        duration: '25',
        kcal: 320,
        reps: 0,
        instructions: [],
        benefits: [],
      ),
      ExerciseModel(
        id: 3,
        name: 'Push-up Challenge',
        description: 'Chest and arm workout',
        difficulty: 'Intermediate',
        category: Goal.body_building,
        image: '',
        duration: '15',
        kcal: 120,
        reps: 50,
        instructions: [],
        benefits: [],
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: exercises.map((exercise) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fitness_center, color: Colors.grey),
              ),
              title: Text(
                exercise.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    exercise.difficulty,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildExerciseTag('${exercise.duration} min'),
                      const SizedBox(width: 8),
                      if (exercise.reps > 0)
                        _buildExerciseTag('${exercise.reps} reps'),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    exercise.kcal.toString(),
                    style: const TextStyle(
                      color: Color(0xffE91E63),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'kcal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExerciseTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 12,
        ),
      ),
    );
  }
}
