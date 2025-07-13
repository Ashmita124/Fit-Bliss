import 'package:fitbliss/data/functions/utils.dart';
import 'package:fitbliss/data/models/user_model.dart';
import 'package:fitbliss/data/services/local_storage/uid.dart';
import 'package:fitbliss/main.dart';
import 'package:fitbliss/screens/auth/forgot_password.dart';
import 'package:fitbliss/screens/auth/sign_up.dart';
import 'package:fitbliss/screens/home/home.dart';
import 'package:fitbliss/screens/onboarding/age.dart';
import 'package:fitbliss/screens/onboarding/goal.dart';
import 'package:fitbliss/screens/onboarding/level.dart';
import 'package:fitbliss/screens/onboarding/weight.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _globalError;
  Future<UserModel?> signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      Get.snackbar(
        "Form Error",
        "Please fix the errors above.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      return null;
    }

    setState(() => _isLoading = true);

    try {
      final res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = res.user;
      if (user != null) {
        // ✅ Fetch profile
        final profileRes = await supabase
            .from('profiles')
            .select()
            .eq('UID', user.id)
            .maybeSingle();

        if (profileRes == null) {
          Get.snackbar(
            "Profile Error",
            "Login succeeded, but profile not found.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.black,
          );
          return null;
        }

        final userModel = UserModel.fromMap(profileRes);
        uidStorage.saveUID(user.id);

        if (userModel.age == null) {
          Get.off(() => AgeSelector());
          return null;
        } else if (userModel.weight == null) {
          Get.off(() => WeightSelector());
          return null;
        } else if (userModel.level == null) {
          Get.off(() => LevelSelector());
          return null;
        } else if (userModel.goal == null) {
          Get.off(() => GoalSelector());
          return null;
        }

        Get.snackbar(
          "Success",
          "Login successful!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.black,
        );

        Get.off(
          () => HomeScreen(),
        );
        return userModel;
      } else {
        Get.snackbar(
          "Login Failed",
          "Please check your credentials.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black,
        );
        return null;
      }
    } catch (e) {
      handleSupabaseError(e);
      return null;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                const Text(
                  "Welcome to FitBliss!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Hello there, sign in to continue!",
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),

                const SizedBox(height: 28),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email address",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "test@gmail.com",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                          );
                          if (value == null ||
                              !emailRegex.hasMatch(value.trim())) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      const Text("Password", style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: TextButton(
                      //     onPressed: () {
                      //       Get.to(() => ForgotPasswordScreen());
                      //     },
                      //     child: const Text(
                      //       "Forgot Password?",
                      //       style: TextStyle(color: Colors.black87),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 10),

                      if (_globalError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _globalError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _isLoading ? null : signIn,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // const Center(
                      //   child: Text(
                      //     "Or login with",
                      //     style: TextStyle(fontSize: 14),
                      //   ),
                      // ),

                      // const SizedBox(height: 20),

                      // // Google Button
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: OutlinedButton.icon(
                      //     icon: Image.network(
                      //       'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_"G"_logo.svg/240px-Google_"G"_logo.svg.png',
                      //       height: 20,
                      //     ),
                      //     label: const Text(
                      //       "Continue with Google",
                      //       style: TextStyle(fontSize: 14),
                      //     ),
                      //     onPressed: () {
                      //       // TODO: Add Google sign-in
                      //     },
                      //   ),
                      // ),

                      // const SizedBox(height: 12),

                      // // Facebook Button
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: ElevatedButton.icon(
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: const Color(0xFF1877F2),
                      //       padding: const EdgeInsets.symmetric(vertical: 14),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //     ),
                      //     icon: const Icon(Icons.facebook, color: Colors.white),
                      //     label: const Text(
                      //       "Continue with Facebook",
                      //       style: TextStyle(color: Colors.white, fontSize: 14),
                      //     ),
                      //     onPressed: () {
                      //       // TODO: Add Facebook sign-in
                      //     },
                      //   ),
                      // ),

                      // const SizedBox(height: 30),
                      InkWell(
                        onTap: () {
                          Get.off(() => CreateAccountScreen());
                        },
                        child: const Center(
                          child: Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              children: [
                                TextSpan(
                                  text: "Create one!",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
