import 'package:get/get.dart';
import '../../../appground_screen.dart';
import '../screens/login_screen.dart';
import 'auth_controller.dart';

class SplashController extends GetxController {
  final _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    // Try to refresh token (checks if user has valid refresh token saved)
    final success = await _authController.refreshToken();

    if (success) {
      // User has valid token, navigate to home
      Get.offAll(() => const AppGroundScreen());
    } else {
      // No valid token, navigate to login
      Get.offAll(() => LoginScreen());
    }
  }
}
