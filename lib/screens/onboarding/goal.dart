// ignore_for_file: constant_identifier_names

import 'package:fitbliss/data/services/local_storage/uid.dart';
import 'package:fitbliss/main.dart';
import 'package:fitbliss/screens/home/home.dart';
import 'package:fitbliss/screens/onboarding/level.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalSelector extends StatefulWidget {
  const GoalSelector({super.key});

  @override
  State<GoalSelector> createState() => _GoalSelectorState();
}

class _GoalSelectorState extends State<GoalSelector> {
  Goal currentGoal = Goal.weight_loss;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.off(() => const LevelSelector());
                        },
                        child: Container(
                          height: 32,
                          width: 32,
                          alignment: const Alignment(-1, 0),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("Step 5 of 5"),
                  const Text(
                    "WHAT'S YOUR GOAL?",
                    style: TextStyle(fontSize: 30),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ...[
              for (Goal goal in Goal.values)
                InkWell(
                  onTap: () {
                    setState(() {
                      currentGoal = goal;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    height: 55,
                    alignment: const Alignment(0, 0),
                    decoration: BoxDecoration(
                      color: currentGoal == goal ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 1,
                        color: const Color(0xff696969).withAlpha(25),
                      ),
                    ),
                    child: Text(
                      goal.name.capitalizeFirst!.replaceAll("_", " "),
                      style: TextStyle(
                        color: currentGoal == goal
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                        fontFamily: GoogleFonts.dmSans().fontFamily,
                      ),
                    ),
                  ),
                ),
            ],
            const Spacer(flex: 4),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        try {
                          String? uid = await uidStorage.getUID();
                          await supabase
                              .from('profiles')
                              .update({
                                'goal': currentGoal.name,
                              })
                              .eq("UID", uid!);
                          Get.off(() => const HomeScreen());
                        } catch (e) {
                          // handle error if needed
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2D6B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "FINISH STEPS",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum Goal {
  weight_loss,
  improve_fitness,
  body_building,
  strength_training,
  flexibility,
  cardio,
  balance,
  rehabilitation,
}
