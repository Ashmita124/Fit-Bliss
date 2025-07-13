import 'package:fitbliss/data/models/exercise_model.dart';
import 'package:fitbliss/data/models/nutrition_model.dart';
import 'package:fitbliss/data/models/user_model.dart';
import 'package:fitbliss/data/services/get/exercise.dart';
import 'package:fitbliss/data/services/get/nutrition.dart';
import 'package:fitbliss/data/services/local_storage/uid.dart';
import 'package:fitbliss/main.dart';
import 'package:fitbliss/screens/exercise/exercise_detail.dart';
import 'package:fitbliss/screens/exercise/work_out.dart';
import 'package:fitbliss/screens/home/profile.dart';
import 'package:fitbliss/screens/home/progress.dart';
import 'package:fitbliss/screens/nutrition/meal_plan.dart';
import 'package:fitbliss/screens/nutrition/nutrition_detail.dart';
import 'package:fitbliss/screens/onboarding/goal.dart';
// Add this import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MainController mainController = Get.put(MainController());
  UserModel? user;
  Goal? selectedGoal;
  List<NutritionModel> randomNutritionItems = [];

  @override
  void initState() {
    getUser();
    loadRandomNutrition();
    super.initState();
  }

  getUser() async {
    String? uid = await uidStorage.getUID();
    final profileRes = await supabase
        .from('profiles')
        .select()
        .eq('UID', uid!)
        .maybeSingle();
    user = UserModel.fromMap(profileRes!);

    if (user?.goal != null) {
      selectedGoal = ExerciseCategoryExtension.fromString(user!.goal!);
    } else {
      selectedGoal = Goal.improve_fitness;
    }

    setState(() {});
  }

  void loadRandomNutrition() async {
    await nutritionController.loadNutrition();
    if (nutritionController.nutritionItems.isNotEmpty) {
      final shuffled = List.of(nutritionController.nutritionItems)..shuffle();
      setState(() {
        randomNutritionItems = shuffled
            .take(4)
            .toList(); // Increased to 4 items for better vertical display
      });
    }
  }

  Future<void> _updateGoal(Goal newGoal) async {
    try {
      await supabase
          .from('profiles')
          .update({'goal': newGoal.name})
          .eq("UID", user!.id);

      setState(() {
        selectedGoal = newGoal;
        user = user!.copyWith(goal: newGoal.name);
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to update goal: ${e.toString()}");
    }
  }

  Widget _buildExerciseCard(ExerciseModel exercise) {
    return InkWell(
      onTap: () {
        Get.to(() => ExerciseDetailScreen(exercise: exercise));
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                exercise.image,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffE91E63),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Icon(Icons.error),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        exercise.duration,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Spacer(),
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${exercise.kcal} kcal',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseListTile(ExerciseModel exercise) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          exercise.image,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 60,
            height: 60,
            color: Colors.grey[200],
            child: Icon(Icons.error),
          ),
        ),
      ),
      title: Text(
        exercise.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          Icon(Icons.timer, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text(exercise.duration, style: TextStyle(fontSize: 12)),
          SizedBox(width: 16),
          Icon(Icons.local_fire_department, size: 14, color: Colors.grey),
          SizedBox(width: 4),
          Text('${exercise.kcal} kcal', style: TextStyle(fontSize: 12)),
        ],
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Get.to(() => ExerciseDetailScreen(exercise: exercise));
      },
    );
  }

  Widget _buildNutritionItem(NutritionModel nutrition) {
    return InkWell(
      onTap: () {
        Get.to(() => NutritionDetailScreen(nutrition: nutrition));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'nutrition-image-${nutrition.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  nutrition.image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffE91E63),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.food_bank,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nutrition.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${nutrition.calories} kcal',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Spacer(),
                      Chip(
                        label: Text(
                          nutrition.category.displayName,
                          style: TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.grey[200],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String routeName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.dmSans().fontFamily,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.toNamed(routeName);
            },
            child: Text(
              "See All",
              style: TextStyle(
                color: Color(0xffE91E63),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    List<ExerciseModel> categoryExercises = [];
    List<ExerciseModel> popularExercises = [];
    List<ExerciseModel> additionalExercises = [];

    if (selectedGoal != null) {
      categoryExercises = exerciseController.getByCategory(selectedGoal!);

      if (categoryExercises.isNotEmpty) {
        popularExercises = (List.of(
          categoryExercises,
        )..shuffle()).take(2).toList();
        final remaining = categoryExercises
            .where((e) => !popularExercises.contains(e))
            .toList();
        additionalExercises = (remaining..shuffle()).take(4).toList();
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                color: Color(0xffE91E63),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "FIT BLISS",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              fontFamily: GoogleFonts.dmSans().fontFamily,
                            ),
                          ),
                          Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(width: 4),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(Icons.person),
                          ),
                          SizedBox(width: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, Good Morning",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                ),
                              ),
                              Text(
                                user?.name.capitalizeFirst ?? "Guest",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextField(
                        onTapOutside: (tap) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Search",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: 16),
              Image.asset("assets/images/main.png", width: Get.width * 0.9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      bottom: 8,
                      top: 16,
                    ),
                    child: Text(
                      "SELECT YOUR GOAL",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final goal = Goal.values[index];
                        final name = goal.name
                            .split("_")
                            .map((e) => e.capitalizeFirst)
                            .join(" ");
                        final isSelected = selectedGoal == goal;

                        return ChoiceChip(
                          label: Text(
                            name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _updateGoal(goal);
                            }
                          },
                          backgroundColor: Colors.grey[300],
                          selectedColor: Color(0xffE91E63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => SizedBox(width: 8),
                      itemCount: Goal.values.length,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (popularExercises.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Popular Exercises", '/exercises'),
                ...popularExercises
                    .map((exercise) => _buildExerciseCard(exercise))
                    .toList(),
              ],
            ),
          ),
        if (additionalExercises.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("More Exercises", '/exercises'),
                ...additionalExercises
                    .map((exercise) => _buildExerciseListTile(exercise))
                    .toList(),
                SizedBox(height: 8),
              ],
            ),
          ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Workout Planner", '/workout-planner'),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: InkWell(
                  onTap: () {
                    Get.to(() => WorkoutPlannerScreen());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: Color(0xffE91E63),
                          size: 40,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Create Your Workout",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: GoogleFonts.dmSans().fontFamily,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Build a custom workout plan",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Color(0xffE91E63)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
        if (randomNutritionItems.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Meal Plans", '/nutrition'),
                ...randomNutritionItems
                    .map((nutrition) => _buildNutritionItem(nutrition))
                    .toList(),
                SizedBox(height: 8),
              ],
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (mainController.currentIndex.value) {
          case 0: // Home
            return _buildHomeContent();
          case 1: // Meal Plans
            return MealPlansScreen();
          case 2: // Progress
            return ProgressDashboard();
          case 3: // Profile
            return ProfileScreen(user: user);
          default:
            return _buildHomeContent();
        }
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: mainController.currentIndex.value,
          onTap: mainController.changePage,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xffE91E63), // Match your theme color
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              label: 'Meal Plans',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
