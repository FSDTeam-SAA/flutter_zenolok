import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_logo.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/form_error_message.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';
import '../widgets/otp_code_field.dart';

class OtpVerificationToCompleteRegister extends StatefulWidget {
  const OtpVerificationToCompleteRegister({super.key, required this.email});
  final String email;

  @override
  State<OtpVerificationToCompleteRegister> createState() =>
      _OtpVerificationToCompleteRegisterState();
}

class _OtpVerificationToCompleteRegisterState
    extends State<OtpVerificationToCompleteRegister> {
  late TapGestureRecognizer _resendOtp;
  final _authController = Get.find<AuthController>();
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    _resendOtp = TapGestureRecognizer()
      ..onTap = () {
        _authController.resendOTP(widget.email);
      };

    super.initState();
  }

  _submit() {
    String otp = _controllers.map((c) => c.text).join();
    _authController.verifyAccount(widget.email, otp);
  }

  @override
  void dispose() {
    _resendOtp.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _maskEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;
    final parts = email.split('@');
    final local = parts[0];
    final domain = parts[1];
    
    if (local.length <= 2) return email;
    
    final prefix = local.substring(0, 2);
    return '$prefix*********@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppScaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 51),
                  // AppLogo(images: AppImages.appLogoLandscape),
                  SizedBox(height: 74),
              
                  Text(
                    'Enter OTP',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'We have share a code of your registered email address\n${_maskEmail(widget.email)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 32),
              
                  Obx(() {
                    final error = _authController.errorMessage.value;
                    if (error.isNotEmpty) {
                      return FormErrorMessage(message: error);
                    }
                    return const SizedBox.shrink(); // return empty widget
                  }),
              
                  // Custom OTP Fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 48,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                  ),
              
                  SizedBox(height: 32),
              
                  // Verify Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Obx(
                      () => PrimaryButton(
                        onPressed: _submit,
                        isLoading: _authController.isLoading.value,
                        text: 'Verify',
                        backgroundColor: const Color(0xFF21A9F3),
                        textColor: Colors.white,
                        borderRadius: 30,
                        height: 52,
                      ),
                    ),
                  ),
              
                  SizedBox(height: 24),
              
                  // Resend Email Text
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Didn\'t see your verification email? ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                        children: [
                          TextSpan(
                            text: 'Resend email',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF21A9F3),
                            ),
                            recognizer: _resendOtp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
