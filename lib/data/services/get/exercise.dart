import 'package:fitbliss/data/exercise.dart';
import 'package:fitbliss/data/models/exercise_model.dart';
import 'package:fitbliss/screens/onboarding/goal.dart';
import 'package:get/get.dart';

class ExerciseController extends GetxController {
  List<ExerciseModel> _exercises = [];
  bool _isLoaded = false;

  List<ExerciseModel> get exercises => _exercises;
  bool get isLoaded => _isLoaded;

  Future<void> loadExercises() async {
    if (_isLoaded) return;

    try {
      _exercises = [
        for (final exercise in exerciseData) ExerciseModel.fromJson(exercise),
      ];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load exercises: $e');
      _exercises = []; // Reset or keep partial list?
    }

    _isLoaded = true;
    update();
  }

  // Add a public method to mark as loaded
  void markAsLoaded() {
    _isLoaded = true;
    update();
  }

  // Get exercises by category
  List<ExerciseModel> getByCategory(Goal category) {
    return _exercises.where((e) => e.category == category).toList();
  }

  // Get exercises by difficulty
  List<ExerciseModel> getByDifficulty(String difficulty) {
    return _exercises.where((e) => e.difficulty == difficulty).toList();
  }
}

final ExerciseController exerciseController = Get.put(ExerciseController());
