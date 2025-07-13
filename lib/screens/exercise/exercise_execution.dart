import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitbliss/data/models/exercise_model.dart';
import 'package:get/get.dart';

class ExerciseExecutionScreen extends StatefulWidget {
  final ExerciseModel exercise;
  final VoidCallback? onExerciseCompleted;

  const ExerciseExecutionScreen({
    super.key,
    required this.exercise,
    this.onExerciseCompleted,
  });

  @override
  State<ExerciseExecutionScreen> createState() =>
      _ExerciseExecutionScreenState();
}

class _ExerciseExecutionScreenState extends State<ExerciseExecutionScreen> {
  int _secondsElapsed = 0;
  bool _isRunning = false;
  late Timer _timer;
  bool _exerciseCompleted = false;
  int _currentStepIndex = 0;
  final PageController _stepController = PageController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _stepController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  void _toggleTimer() {
    setState(() => _isRunning = !_isRunning);
  }

  void _completeExercise() {
    _timer.cancel();
    setState(() => _exerciseCompleted = true);

    if (widget.onExerciseCompleted != null) {
      widget.onExerciseCompleted!();
      Get.back();
    } else {
      _showCompletionDialog();
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text('You completed ${widget.exercise.name}!'),
            Text('Total time: ${_formatTime(_secondsElapsed)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) => Get.back());
  }

  void _nextStep() {
    if (_currentStepIndex < widget.exercise.instructions.length - 1) {
      setState(() => _currentStepIndex++);
      _stepController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStepIndex > 0) {
      setState(() => _currentStepIndex--);
      _stepController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Execution'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isRunning) _toggleTimer();
            Get.back();
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            // Exercise Image with overlay
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.exercise.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      widget.exercise.name,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.exercise.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Timer and Controls
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURRENT TIME',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(_secondsElapsed),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _exerciseCompleted
                              ? Colors.green
                              : const Color(0xffE91E63),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!_exerciseCompleted) ...[
                        IconButton(
                          icon: Icon(
                            _isRunning
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            size: 40,
                            color: const Color(0xffE91E63),
                          ),
                          onPressed: _toggleTimer,
                        ),
                        const SizedBox(width: 16),
                      ],
                      IconButton(
                        icon: const Icon(
                          Icons.replay,
                          size: 30,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _secondsElapsed = 0;
                            _exerciseCompleted = false;
                            _isRunning = false;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.all(16),
              width: Get.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (
                    int index = 0;
                    index < widget.exercise.instructions.length;
                    index++
                  )
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "${index + 1}) ${widget.exercise.instructions[index]}",
                        style: const TextStyle(
                          // fontSize: 10,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Spacer(),

            Container(
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
                children: [
                  // Back button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        'BACK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Complete button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _exerciseCompleted
                            ? Colors.green
                            : const Color(0xffE91E63),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _exerciseCompleted ? null : _completeExercise,
                      child: Text(
                        _exerciseCompleted ? 'COMPLETED' : 'MARK DONE',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
