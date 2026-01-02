import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/theme/input_decoration_extensions.dart';
import 'package:flutx_core/core/theme/gap.dart';
import 'package:get/get.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key, required this.email, required this.otp});
  final String email;
  final String otp;

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final TextEditingController _passwordTEController = TextEditingController();
  final TextEditingController _confirmPasswordTEController = TextEditingController();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    _passwordTEController.dispose();
    _confirmPasswordTEController.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (mounted) FocusScope.of(context).unfocus();
    
    Get.find<AuthController>().setNewPass(
      widget.email,
      widget.otp,
      _passwordTEController.text,
    );
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
                            'Reset Password',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textColor),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please enter your new password',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.secondaryText),
                          ),
                          SizedBox(height: 32),
                          ValueListenableBuilder<bool>(
                            valueListenable: _obscurePassword,
                            builder: (context, obscure, _) {
                              return TextFormField(
                                controller: _passwordTEController,
                                focusNode: _passwordFocus,
                                obscureText: obscure,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(color: AppColors.textColor),
                                decoration: context.primaryInputDecoration.copyWith(
                                  hintText: "New Password",
                                  fillColor: Colors.white,
                                  suffixIcon: IconButton(
                                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.prefixIconColor),
                                    onPressed: () => _obscurePassword.value = !obscure,
                                  ),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          Gap.h16,
                          ValueListenableBuilder<bool>(
                            valueListenable: _obscureConfirmPassword,
                            builder: (context, obscure, _) {
                              return TextFormField(
                                controller: _confirmPasswordTEController,
                                focusNode: _confirmPasswordFocus,
                                obscureText: obscure,
                                textInputAction: TextInputAction.done,
                                style: TextStyle(color: AppColors.textColor),
                                decoration: context.primaryInputDecoration.copyWith(
                                  hintText: "Confirm Password",
                                  fillColor: Colors.white,
                                  suffixIcon: IconButton(
                                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.prefixIconColor),
                                    onPressed: () => _obscureConfirmPassword.value = !obscure,
                                  ),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                ),
                                validator: (value) {
                                  if (value != _passwordTEController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _submit(),
                              );
                            },
                          ),
                          SizedBox(height: 32),
                          PrimaryButton(isLoading: false, onPressed: _submit, text: "Continue", backgroundColor: const Color(0xFF21A9F3), textColor: Colors.white, borderRadius: 30, height: 52),
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
