import 'package:flutter/material.dart';
import 'package:flutter_zenolok/core/theme/input_decoration_extensions.dart';
import 'package:flutter_zenolok/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter_zenolok/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutx_core/core/theme/gap.dart';
import 'package:flutx_core/core/validation/validators.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/form_error_message.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_controller.dart';
import '../controller/remember_me_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);

  /// [Controller]
  final _authController = Get.find<AuthController>();
  final rememberMeController = Get.put(RememberMeController());


  @override
  void dispose() {
    _obscurePassword.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocus.dispose();
    _passwordFocus.dispose();

    // _authController.dispose();
    super.dispose();
  }

  /// [Submit the form]
  /// Check the email and password validations
  ///
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Hide keyboard immediately
    if (mounted) FocusScope.of(context).unfocus();

    _authController.login(_emailController.text, _passwordController.text);
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        
                        // No logo - cleaner design per screenshot
          
                        Text(
                          'Log in',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
          
                        SizedBox(height: 12),
          
                        /// [Api Error messages]
                        ///
                        Obx(() {
                          final error = _authController.errorMessage.value;
                          if (error.isNotEmpty) {
                            return FormErrorMessage(message: error);
                          }
                          return const SizedBox.shrink(); // return empty widget
                        }),
          
                        // AnimatedBuilder(
                        //   animation: _authController,
                        //   builder: (context, _) {
                        //     return
                        //
                        //   },
                        // ),
          
                        // Social buttons (inlined: Google image, Apple icon)
                        SizedBox(height: 8),
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
                                'Sign in with Google',
                                style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12),

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
                                'Sign in with Google',
                                style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.w600),
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
                              child: Text('or sign in with', style: TextStyle(color: AppColors.secondaryText)),
                            ),
                            Expanded(
                              child: Divider(color: Colors.grey[300], thickness: 1),
                            ),
                          ],
                        ),
          
                        SizedBox(height: 18),
          
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
                            fillColor: Colors.white,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColors.prefixIconColor,
                            ),
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
                          onFieldSubmitted: (_) => FocusScope.of(
                            context,
                          ).requestFocus(_passwordFocus),
                          autofillHints: const [AutofillHints.email],
                        ),
          
                        Gap.h16,
          
                        /// [Text field] Password
                        ValueListenableBuilder<bool>(
                          valueListenable: _obscurePassword,
                          builder: (context, obscure, _) {
                            return TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              obscureText: obscure,
                              textInputAction: TextInputAction.done,
                              style: TextStyle(color: AppColors.textColor),
                              decoration: context.primaryInputDecoration.copyWith(
                                hintText: "Password",
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.lock_outlined,
                                  color: AppColors.prefixIconColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscure ? Icons.visibility_off : Icons.visibility,
                                    color: AppColors.prefixIconColor,
                                  ),
                                  onPressed: () => _obscurePassword.value = !obscure,
                                ),
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
          
                              // validator: Validators.password,
                              onFieldSubmitted: (_) => _submit(),
                            );
                          },
                        ),
          
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Obx(
                                  () => Checkbox(
                                    value:
                                        rememberMeController.rememberMe.value,
                                    activeColor: Color(0xFF21A9F3),
                                    // fill color when checked
                                    checkColor: AppColors.prefixIconColor,
                                    //  tick color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    side: MaterialStateBorderSide.resolveWith((
                                      states,
                                    ) {
                                      if (states.contains(
                                        MaterialState.selected,
                                      )) {
                                        //  Border when checked
                                        return BorderSide(
                                          color: AppColors.prefixIconColor,
                                          width: 2,
                                        );
                                      }
                                      // Border when unchecked
                                      return BorderSide(
                                        color: AppColors.prefixIconColor,
                                        width: 1,
                                      );
                                    }),
                                    onChanged: (_) =>
                                        rememberMeController.toggleRememberMe(),
                                  ),
                                ),
          
                                GestureDetector(
                                  onTap: rememberMeController.toggleRememberMe,
                                  // tap text also toggles
                                  child: const Text(
                                    "Keep me signed in",
                                    style: TextStyle(
                                      color: AppColors.textColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
          
                            TextButton(
                              onPressed: () {
                                Get.to(ResetPasswordScreen());
                              },
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Color(0xFF21A9F3),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap.h16,
          
                        /// [Button] Sign In
                        // ListenableBuilder(
                        //   listenable: _authController,
                        //   builder: (context, _) {
                        //     return PrimaryButton(
                        //       isLoading: _authController.isLoading.value,
                        //       onPressed: _submit,
                        //       text: "Sign In",
                        //     );
                        //   },
                        // ),
                        Obx(
                          () => PrimaryButton(
                            isLoading: _authController.isLoading.value,
                            onPressed: _submit,
                            text: "Login",
                            backgroundColor: const Color(0xFF21A9F3),
                            textColor: Colors.white,
                            borderRadius: 30,
                            height: 52,
                          ),
                        ),
          
                        Gap.h16,
          
                        SizedBox(height: 24),
          
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: AppColors.secondaryText),
                              ),
                              GestureDetector(
                                onTap: () => Get.to(() => SignupScreen()),
                                child: Text(
                                  'Sign up here',
                                  style: TextStyle(color: Color(0xFF21A9F3), fontWeight: FontWeight.w600),
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
            ],
          ),
        ),
      ),
    );
  }

  
}
