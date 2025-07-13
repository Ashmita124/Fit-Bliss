import 'dart:async';
import 'dart:math';

import 'package:fitbliss/data/services/get/exercise.dart';
import 'package:fitbliss/screens/exercise/exercise_execution.dart';
import 'package:flutter/material.dart';
import 'package:fitbliss/data/models/exercise_model.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// New class to handle unique keys for reorderable items
class SelectedExercise {
  final ExerciseModel exercise;
  final String uniqueId;

  SelectedExercise(this.exercise)
    : uniqueId = '${exercise.id}_${Random().nextInt(100000)}';
}

class WorkoutPlannerController extends GetxController {
  final List<SelectedExercise> selectedExercises = [];
  String workoutName = '';
  bool isEditing = false;

  void toggleExerciseSelection(ExerciseModel exercise) {
    if (selectedExercises.any((item) => item.exercise == exercise)) {
      selectedExercises.removeWhere((item) => item.exercise == exercise);
    } else {
      selectedExercises.add(SelectedExercise(exercise));
    }
    update();
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final exercise = selectedExercises.removeAt(oldIndex);
    selectedExercises.insert(newIndex, exercise);
    update();
  }

  void clearSelection() {
    selectedExercises.clear();
    update();
  }

  void toggleEditing() {
    isEditing = !isEditing;
    update();
  }

  void updateWorkoutName(String name) {
    workoutName = name;
    update();
  }
}

class WorkoutPlannerScreen extends StatelessWidget {
  final WorkoutPlannerController plannerController = Get.put(
    WorkoutPlannerController(),
  );
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<WorkoutPlannerController>(
          builder: (controller) => Text(
            controller.isEditing ? 'Edit Workout' : 'Create Workout Plan',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffE91E63),
        elevation: 0,
        actions: [
          GetBuilder<WorkoutPlannerController>(
            builder: (controller) => controller.isEditing
                ? IconButton(
                    icon: Icon(Icons.check, color: Colors.white),
                    onPressed: () => controller.toggleEditing(),
                  )
                : SizedBox(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffE91E63).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Selected Exercises List
            Expanded(
              child: GetBuilder<WorkoutPlannerController>(
                builder: (controller) => controller.selectedExercises.isEmpty
                    ? _buildEmptyState()
                    : _buildExerciseList(controller),
              ),
            ),

            // Start Workout Button
            GetBuilder<WorkoutPlannerController>(
              builder: (controller) => controller.selectedExercises.isNotEmpty
                  ? SafeArea(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffE91E63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                        onPressed: () {
                          Get.to(
                            () => WorkoutExecutionScreen(
                              workoutName: controller.workoutName,
                              exercises: controller.selectedExercises
                                  .map((e) => e.exercise)
                                  .toList(),
                            ),
                          );
                        },
                        child: Text(
                          'START WORKOUT',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffE91E63),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final selected = await Get.bottomSheet<List<ExerciseModel>>(
            ExerciseSelectionBottomSheet(),
            isScrollControlled: true,
          );
          if (selected != null && selected.isNotEmpty) {
            selected.forEach((exercise) {
              plannerController.selectedExercises.add(
                SelectedExercise(exercise),
              );
            });
            plannerController.update();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 24),
          Text(
            'No Exercises Added',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add exercises',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(WorkoutPlannerController controller) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              Text(
                '${controller.selectedExercises.length} Exercises',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Spacer(),
              Text(
                'Drag to reorder',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              Icon(Icons.drag_handle, size: 16, color: Colors.grey[500]),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: EdgeInsets.only(bottom: 100),
            itemCount: controller.selectedExercises.length,
            onReorder: controller.reorderExercises,
            itemBuilder: (context, index) {
              final selectedExercise = controller.selectedExercises[index];
              final exercise = selectedExercise.exercise;
              return Container(
                key: ValueKey(selectedExercise.uniqueId), // Fixed key issue
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(exercise.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      exercise.name,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${exercise.duration} • ${exercise.difficulty}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                      onPressed: () {
                        controller.selectedExercises.removeAt(index);
                        controller.update();
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ExerciseSelectionBottomSheet extends StatefulWidget {
  const ExerciseSelectionBottomSheet();

  @override
  _ExerciseSelectionBottomSheetState createState() =>
      _ExerciseSelectionBottomSheetState();
}

class _ExerciseSelectionBottomSheetState
    extends State<ExerciseSelectionBottomSheet> {
  final ExerciseController exerciseController = Get.find();
  final WorkoutPlannerController plannerController = Get.find();
  final List<ExerciseModel> _selected = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Select Exercises',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: exerciseController.exercises.length,
              itemBuilder: (context, index) {
                final exercise = exerciseController.exercises[index];
                final isSelected = _selected.contains(exercise);
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(0xffE91E63).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selected.add(exercise);
                        } else {
                          _selected.remove(exercise);
                        }
                      });
                    },
                    title: Text(
                      exercise.name,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Color(0xffE91E63) : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      exercise.category.toString().split('.').last,
                      style: TextStyle(
                        color: isSelected
                            ? Color(0xffE91E63)
                            : Colors.grey[600],
                      ),
                    ),
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(exercise.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    activeColor: Color(0xffE91E63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffE91E63),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.back(result: _selected);
                  },
                  child: Text(
                    'Add Selected (${_selected.length})',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

// Updated WorkoutExecutionScreen
class WorkoutExecutionScreen extends StatefulWidget {
  final String workoutName;
  final List<ExerciseModel> exercises;

  const WorkoutExecutionScreen({
    required this.workoutName,
    required this.exercises,
  });

  @override
  _WorkoutExecutionScreenState createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  int _currentExerciseIndex = 0;
  int _totalElapsedSeconds = 0;
  Timer? _workoutTimer;
  bool _isWorkoutPaused = false;

  @override
  void initState() {
    super.initState();
    _startWorkoutTimer();
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    super.dispose();
  }

  void _startWorkoutTimer() {
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isWorkoutPaused) {
        setState(() => _totalElapsedSeconds++);
      }
    });
  }

  void _togglePauseResume() {
    setState(() => _isWorkoutPaused = !_isWorkoutPaused);
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.exercises.length - 1) {
      setState(() => _currentExerciseIndex++);
    } else {
      _completeWorkout();
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() => _currentExerciseIndex--);
    }
  }

  void _completeWorkout() {
    _workoutTimer?.cancel();
    Get.back();
    _showCompletionDialog();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Workout Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text('You completed ${widget.workoutName}!'),
            Text('Total time: ${_formatTime(_totalElapsedSeconds)}'),
            const SizedBox(height: 16),
            Text(
              'Great job! You burned approximately ${_calculateTotalCalories()} calories.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  int _calculateTotalCalories() {
    return widget.exercises.fold(
      0,
      (total, exercise) => total + exercise.kcal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.exercises[_currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.workoutName,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '${_currentExerciseIndex + 1}/${widget.exercises.length}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isWorkoutPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePauseResume,
          ),
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Workout Time'),
                  content: Text(
                    'Total time: ${_formatTime(_totalElapsedSeconds)}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentExerciseIndex + 1) / widget.exercises.length,
            backgroundColor: Colors.grey[300],
            minHeight: 4,
            color: const Color(0xffE91E63),
          ),

          // Current exercise
          Expanded(
            child: ExerciseExecutionCard(
              exercise: currentExercise,
              isLast: _currentExerciseIndex == widget.exercises.length - 1,
              onCompleted: _nextExercise,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentExerciseIndex > 0)
              OutlinedButton(
                onPressed: _previousExercise,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                child: const Text('Previous'),
              ),
            ElevatedButton(
              onPressed: _nextExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffE91E63),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                _currentExerciseIndex == widget.exercises.length - 1
                    ? 'Finish Workout'
                    : 'Next Exercise',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Exercise Card
class ExerciseExecutionCard extends StatelessWidget {
  final ExerciseModel exercise;
  final bool isLast;
  final VoidCallback onCompleted;

  const ExerciseExecutionCard({
    required this.exercise,
    required this.isLast,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Exercise image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: exercise.image.isNotEmpty
                  ? Image.network(exercise.image, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.fitness_center, size: 60),
                      ),
                    ),
            ),
          ),

          // Exercise details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        exercise.difficulty.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getDifficultyColor(exercise.difficulty),
                    ),
                    Chip(
                      label: Text('${exercise.duration}'),
                      backgroundColor: Colors.grey[200],
                    ),
                    Chip(
                      label: Text('${exercise.kcal} kcal'),
                      backgroundColor: Colors.grey[200],
                    ),
                    if (exercise.reps > 0)
                      Chip(
                        label: Text('${exercise.reps} reps'),
                        backgroundColor: Colors.grey[200],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  exercise.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_circle_filled),
                    label: const Text('Start'),
                    onPressed: () => Get.to(
                      () => ExerciseExecutionScreen(
                        exercise: exercise,
                        onExerciseCompleted: onCompleted,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffE91E63),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Skip'),
                    onPressed: onCompleted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
