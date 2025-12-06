import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/theme/input_decoration_extensions.dart';
import 'package:flutx_core/core/theme/gap.dart';
import 'package:flutx_core/core/validation/validators.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _agreeToTerms = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    _agreeToTerms.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms.value) {
      Get.snackbar('Error', 'Please agree to Terms & Conditions');
      return;
    }

    if (mounted) FocusScope.of(context).unfocus();
    // Get.snackbar('Success', 'Sign up functionality will be implemented');
    final authController = Get.find<AuthController>();
    authController.register(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppScaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),

                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios, color: AppColors.textColor, size: 20),
                            onPressed: () => Get.back(),
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            alignment: Alignment.centerLeft,
                          ),
                        ),

                        SizedBox(height: 20),

                        Text(
                          'Sign up',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),

                        SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            children: [
                              // Google button
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(color: AppColors.googleBorderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.googleLogo,
                                      height: 20,
                                      width: 20,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Sign up with Google',
                                      style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 12),

                              // Apple button
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(color: AppColors.googleBorderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.appleLogo,
                                      height: 20,
                                      width: 20,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Sign up with Apple',
                                      style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 18),

                              // OR divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: Colors.grey[300], thickness: 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text('or sign up with', style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
                                  ),
                                  Expanded(
                                    child: Divider(color: Colors.grey[300], thickness: 1),
                                  ),
                                ],
                              ),

                              SizedBox(height: 18),

                              // Username field
                              TextFormField(
                                controller: _usernameController,
                                focusNode: _usernameFocus,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textColor,
                                ),
                                decoration: context.primaryInputDecoration.copyWith(
                                  hintText: "Username",
                                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                                  fillColor: Colors.white,
                                  suffixIcon: Icon(
                                    Icons.person_outline,
                                    color: AppColors.prefixIconColor,
                                  ),
                                  prefixIcon: null,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                ),
                                validator: Validators.name,
                                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                              ),

                              Gap.h16,

                              // Email field
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textColor,
                                ),
                                decoration: context.primaryInputDecoration.copyWith(
                                  hintText: "Email Address",
                                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                                  fillColor: Colors.white,
                                  suffixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppColors.prefixIconColor,
                                  ),
                                  prefixIcon: null,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                ),
                                validator: Validators.email,
                                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                                autofillHints: const [AutofillHints.email],
                              ),

                              Gap.h16,

                              // Password field
                              ValueListenableBuilder<bool>(
                                valueListenable: _obscurePassword,
                                builder: (context, obscure, _) {
                                  return TextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    obscureText: obscure,
                                    textInputAction: TextInputAction.next,
                                    style: TextStyle(color: AppColors.textColor, fontSize: 16),
                                    decoration: context.primaryInputDecoration.copyWith(
                                      hintText: "Password",
                                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                                      fillColor: Colors.white,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscure ? Icons.visibility_off : Icons.visibility,
                                          color: AppColors.prefixIconColor,
                                        ),
                                        onPressed: () => _obscurePassword.value = !obscure,
                                      ),
                                      prefixIcon: null,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                    ),
                                    validator: Validators.password,
                                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocus),
                                  );
                                },
                              ),

                              Gap.h16,

                              // Confirm Password field
                              ValueListenableBuilder<bool>(
                                valueListenable: _obscureConfirmPassword,
                                builder: (context, obscure, _) {
                                  return TextFormField(
                                    controller: _confirmPasswordController,
                                    focusNode: _confirmPasswordFocus,
                                    obscureText: obscure,
                                    textInputAction: TextInputAction.done,
                                    style: TextStyle(color: AppColors.textColor, fontSize: 16),
                                    decoration: context.primaryInputDecoration.copyWith(
                                      hintText: "Confirm Password",
                                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                                      fillColor: Colors.white,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          obscure ? Icons.visibility_off : Icons.visibility,
                                          color: AppColors.prefixIconColor,
                                        ),
                                        onPressed: () => _obscureConfirmPassword.value = !obscure,
                                      ),
                                      prefixIcon: null,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                    ),
                                    validator: (value) {
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (_) => _submit(),
                                  );
                                },
                              ),

                              SizedBox(height: 12),

                              // Terms checkbox
                              Row(
                                children: [
                                  ValueListenableBuilder<bool>(
                                    valueListenable: _agreeToTerms,
                                    builder: (context, agreed, _) {
                                      return Checkbox(
                                        value: agreed,
                                        activeColor: Color(0xFF21A9F3),
                                        checkColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        side: WidgetStateBorderSide.resolveWith((states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return BorderSide(
                                              color: Color(0xFF21A9F3),
                                              width: 1.5,
                                            );
                                          }
                                          return BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 1,
                                          );
                                        }),
                                        onChanged: (_) => _agreeToTerms.value = !agreed,
                                      );
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _agreeToTerms.value = !_agreeToTerms.value,
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'I agree to the ',
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Terms & Conditions',
                                              style: TextStyle(
                                                color: Color(0xFF21A9F3),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Gap.h16,

                              // Sign Up button
                              PrimaryButton(
                                isLoading: false,
                                onPressed: _submit,
                                text: "Sign up",
                                backgroundColor: const Color(0xFF21A9F3),
                                textColor: Colors.white,
                                borderRadius: 30,
                                height: 52,
                              ),

                              SizedBox(height: 20),

                              // Sign in link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Have an account? ",
                                    style: TextStyle(
                                      color: AppColors.textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Text(
                                      'Sign in here',
                                      style: TextStyle(
                                        color: Color(0xFF21A9F3),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
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
