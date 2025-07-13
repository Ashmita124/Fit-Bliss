import 'package:fitbliss/data/functions/utils.dart';
import 'package:fitbliss/main.dart';
import 'package:fitbliss/screens/auth/sign_in.dart';
import 'package:fitbliss/screens/auth/verify_otp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _globalError;
  String? _successMessage;

  Future<void> _forgotPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      Get.snackbar(
        "Form Error",
        "Please fix the errors above.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await supabase.auth.resetPasswordForEmail(
        _emailController.text.trim(),
      );

      Get.snackbar(
        "Email Sent",
        "A password reset link has been sent to your email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );

      Get.to(() => VerifyAccountScreen());
    } catch (e) {
      handleSupabaseError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back
                GestureDetector(
                  onTap: () {
                    Get.off(() => LoginScreen());
                  },
                  child: const Icon(Icons.arrow_back, size: 28),
                ),
                const SizedBox(height: 24),

                // Header
                const Text(
                  "Forgot your password?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please enter your email below to receive your password reset code",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 28),

                // Form
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

                      const SizedBox(height: 24),

                      if (_globalError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _globalError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      if (_successMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(color: Colors.green),
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
                          onPressed: _isLoading ? null : _forgotPassword,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "SEND RESET LINK",
                                  style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.2,
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
        ),
      ),
    );
  }
}
