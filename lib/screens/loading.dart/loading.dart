import 'dart:developer';

import 'package:fitbliss/data/services/get/exercise.dart';
import 'package:fitbliss/data/services/get/nutrition.dart';
import 'package:fitbliss/data/services/local_storage/uid.dart';
import 'package:fitbliss/screens/auth/sign_in.dart';
import 'package:fitbliss/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' hide log;

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _textController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _positionAnimation;
  late final Animation<Color?> _colorAnimation;
  late final Animation<double> _textOpacityAnimation;
  double _progressValue = 0.0;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _textController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _positionAnimation = Tween<double>(begin: -30, end: 30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _colorAnimation =
        ColorTween(
          begin: Colors.cyanAccent,
          end: Colors.pinkAccent,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Initialize particles
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle());
    }
    _controller.addListener(_updateParticles);

    // Start the loading process
    _startLoadingProcess();
  }

  Future<void> _startLoadingProcess() async {
    // Phase 1: Initial loading animation (0-40%)
    for (int i = 0; i <= 40; i += 5) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() => _progressValue = i / 100.0);
      }
    }

    // Phase 2: Load exercises (40-60%)
    await _loadExercises();

    // Phase 3: Load nutrition (60-80%)
    await _loadNutrition();

    // Phase 4: Finalize and navigate (80-100%)
    await _finalizeNavigation();
  }

  Future<void> _loadExercises() async {
    log("getting exercises");

    try {
      if (mounted) setState(() => _progressValue = 0.45);
      await exerciseController.loadExercises();
      log("exercises:: ${exerciseController.exercises.length}");
      if (mounted) setState(() => _progressValue = 0.6);
    } catch (e) {
      if (mounted) setState(() => _progressValue = 0.6);
    }
  }

  Future<void> _loadNutrition() async {
    try {
      if (mounted) setState(() => _progressValue = 0.65);
      await nutritionController.loadNutrition();
      if (mounted) setState(() => _progressValue = 0.8);
    } catch (e) {
      if (mounted) setState(() => _progressValue = 0.8);
    }
  }

  Future<void> _finalizeNavigation() async {
    // Get UID and complete progress
    final uid = await uidStorage.getUID();
    if (mounted) setState(() => _progressValue = 1.0);

    // Add a small delay to show 100% completion
    await Future.delayed(const Duration(milliseconds: 300));

    // Navigate to appropriate screen
    if (uid == null) {
      Get.off(() => const LoginScreen());
    } else {
      Get.off(() => const HomeScreen());
    }
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.update();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_updateParticles);
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.deepPurple, Colors.black87],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: Stack(
          children: [
            // Particle effect
            CustomPaint(
              painter: ParticlePainter(particles: _particles),
              size: Size.infinite,
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(0, _positionAnimation.value),
                    child: Transform.rotate(
                      angle: _rotationAnimation.value * 0.5,
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _colorAnimation.value!.withOpacity(0.6),
                                blurRadius: 25,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  width: 120,
                  height: 120,
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (_, __) {
                      return Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: Text(
                          'FitBliss',
                          style: TextStyle(
                            color: _colorAnimation.value,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: _colorAnimation.value!.withOpacity(0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: _colorAnimation.value!.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 250,
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: _colorAnimation,
                      minHeight: 6,
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

class Particle {
  double x = 0;
  double y = 0;
  double size = Random().nextDouble() * 4 + 2;
  double speedX = Random().nextDouble() * 2 - 1;
  double speedY = Random().nextDouble() * 2 - 1;
  Color color = Colors.white.withOpacity(Random().nextDouble() * 0.3 + 0.2);

  Particle() {
    x = Random().nextDouble() * 400 - 200;
    y = Random().nextDouble() * 400 - 200;
  }

  void update() {
    x += speedX;
    y += speedY;
    if (x.abs() > 200 || y.abs() > 200) {
      x = Random().nextDouble() * 400 - 200;
      y = Random().nextDouble() * 400 - 200;
      speedX = Random().nextDouble() * 2 - 1;
      speedY = Random().nextDouble() * 2 - 1;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(
        Offset(size.width / 2 + particle.x, size.height / 2 + particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
