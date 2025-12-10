import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.email});
  final String email;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _submit() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      Get.find<AuthController>().verifyOTP(widget.email, otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppScaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: AppColors.textColor),
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter verification code',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textColor),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'A verification code has been sent to your email address\nplease enter the code below',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.secondaryText),
                        ),
                        SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return Container(
                              width: 48,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textColor),
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  if (value.length == 1 && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                  if (index == 5 && value.length == 1) {
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 32),
                        PrimaryButton(isLoading: false, onPressed: _submit, text: "Verify", backgroundColor: const Color(0xFF21A9F3), textColor: Colors.white, borderRadius: 30, height: 52),
                        SizedBox(height: 24),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Didn't see your verification email? ", style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                              GestureDetector(
                                onTap: () {},
                                child: Text('Resend email', style: TextStyle(color: Color(0xFF21A9F3), fontWeight: FontWeight.w600, fontSize: 12)),
                              ),
                            ],
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
      ),
    );
  }
}
