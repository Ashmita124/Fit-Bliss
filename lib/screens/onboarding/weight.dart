import 'package:fitbliss/data/services/local_storage/uid.dart';
import 'package:fitbliss/main.dart';
import 'package:fitbliss/screens/onboarding/age.dart';
import 'package:fitbliss/screens/onboarding/level.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

class WeightSelector extends StatefulWidget {
  const WeightSelector({super.key});

  @override
  State<WeightSelector> createState() => _WeightSelectorState();
}

class _WeightSelectorState extends State<WeightSelector> {
  String weight = "0";
  Unit currentUnit = Unit.kg;
  bool _isLoading = false;

  void _onKeyboardTap(String value) {
    setState(() {
      weight = (weight + value).replaceAll("0", "");
    });
  }

  void _onBackspace() {
    setState(() {
      weight = weight.substring(0, weight.length - 1);
      if (weight == "") {
        weight = "0";
      }
    });
  }

  Widget _buildKey(String number, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Get.width / 3,
        height: 65,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 0.8),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        width: Get.width / 3,
        height: 65,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 0.8),
          color: Colors.white,
        ),
        child: const Center(child: Icon(Icons.backspace, size: 22)),
      ),
    );
  }

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
                          Get.off(() => AgeSelector());
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
                  const Text("Step 3 of 5"),
                  const Text(
                    "HOW MUCH DO YOU WEIGHT?",
                    style: TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 64),
                  Container(
                    width: Get.width,
                    alignment: const Alignment(0, 0),
                    child: Container(
                      width: 125,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xff696969).withAlpha(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (Unit unit in Unit.values)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  currentUnit = unit;
                                });
                              },
                              child: Container(
                                decoration: currentUnit == unit
                                    ? BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    : const BoxDecoration(),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                child: Text(
                                  unit.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: const Color(0xff707070).withAlpha(25),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: const Alignment(0, 0),
                    child: Text(
                      "$weight | ${currentUnit.name}",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
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
                                'weight': "$weight ${currentUnit.name}",
                              })
                              .eq("UID", uid!);
                          Get.off(() => const LevelSelector());
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
                        "NEXT STEPS",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (var i = 1; i <= 9; i++)
                  _buildKey(
                    i.toString(),
                    onTap: () => _onKeyboardTap(i.toString()),
                  ),
                Container(
                  width: Get.width / 3,
                  height: 65,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 0.8,
                    ),
                    color: Colors.white,
                  ),
                ),
                _buildKey('0', onTap: () => _onKeyboardTap('0')),
                _buildBackspaceKey(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum Unit { lbs, kg }
