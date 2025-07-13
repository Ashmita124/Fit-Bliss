import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  List<String> otp = ['', '', '', ''];

  void _onKeyboardTap(String value) {
    for (int i = 0; i < otp.length; i++) {
      if (otp[i] == '') {
        setState(() => otp[i] = value);
        break;
      }
    }
  }

  void _onBackspace() {
    for (int i = otp.length - 1; i >= 0; i--) {
      if (otp[i] != '') {
        setState(() => otp[i] = '');
        break;
      }
    }
  }

  Widget _otpBox(String value) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87, width: 1.5),
        color: Colors.white,
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOtpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(otp.length, (index) => _otpBox(otp[index])),
    );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "VERIFY ACCOUNT",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Verify your account by entering verification code we sent to Ashmita@gmail.com",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  _buildOtpRow(),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Resend",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2D6B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: const Text(
                        "RESET PASSWORD",
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
            const Spacer(),
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
                    border: Border.all(color: Colors.grey.shade400, width: 0.8),
                    color: Colors.white,
                  ),
                ),
                _buildKey('0', onTap: () => _onKeyboardTap('0')),
                _buildBackspaceKey(),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
