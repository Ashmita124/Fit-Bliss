import 'package:fitbliss/data/services/local_storage/uid.dart';
import 'package:fitbliss/main.dart';
import 'package:fitbliss/screens/auth/sign_in.dart';
import 'package:fitbliss/screens/onboarding/weight.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:numberpicker/numberpicker.dart';

class AgeSelector extends StatefulWidget {
  const AgeSelector({super.key});

  @override
  State<AgeSelector> createState() => _AgeSelectorState();
}

class _AgeSelectorState extends State<AgeSelector> {
  int age = 24;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
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
                      Get.off(() => LoginScreen());
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
              const Text("Step 2 of 5"),
              const Text(
                "HOW OLD ARE YOU?",
                style: TextStyle(fontSize: 30),
              ),
              Container(
                height: Get.height * 0.6,
                width: Get.width,
                alignment: Alignment.center,
                child: NumberPicker(
                  itemCount: 5,
                  minValue: 15,
                  maxValue: 90,
                  value: age,
                  itemWidth: 70,
                  itemHeight: 40,
                  textStyle: const TextStyle(
                    color: Color(0xff3A4750),
                    fontSize: 14,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: Color.fromARGB(255, 58, 71, 80),
                    fontSize: 24,
                  ),
                  onChanged: (val) {
                    setState(() {
                      age = val;
                    });
                  },
                ),
              ),
              SizedBox(
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
                                .update({'age': age})
                                .eq("UID", uid!);
                            Get.off(() => WeightSelector());
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
            ],
          ),
        ),
      ),
    );
  }
}
