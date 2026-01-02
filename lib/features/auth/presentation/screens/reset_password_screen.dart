import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/theme/input_decoration_extensions.dart';
import 'package:flutx_core/core/theme/gap.dart';
import 'package:flutx_core/core/validation/validators.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = FocusNode();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (mounted) FocusScope.of(context).unfocus();
    Get.find<AuthController>().resetPass(_emailController.text);
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
              child: Form(
                key: _formKey,
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
                            'Forgot Password',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textColor),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Enter your email to receive the verification code',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.secondaryText),
                          ),
                          SizedBox(height: 32),
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(fontSize: 16, color: AppColors.textColor),
                            decoration: context.primaryInputDecoration.copyWith(
                              hintText: "Email Address",
                              fillColor: Colors.white,
                              suffixIcon: Icon(Icons.email_outlined, color: AppColors.prefixIconColor),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            ),
                            validator: Validators.email,
                            onFieldSubmitted: (_) => _submit(),
                            autofillHints: const [AutofillHints.email],
                          ),
                          Gap.h16,
                          SizedBox(height: 16),
                          PrimaryButton(isLoading: false, onPressed: _submit, text: "Submit", backgroundColor: const Color(0xFF21A9F3), textColor: Colors.white, borderRadius: 30, height: 52),
                          SizedBox(height: 24),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Remembered password? ", style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
                                GestureDetector(
                                  onTap: () => Get.to(() => LoginScreen()),
                                  child: Text('Sign in here', style: TextStyle(color: Color(0xFF21A9F3), fontWeight: FontWeight.w600, fontSize: 14)),
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
      ),
    );
  }
}
