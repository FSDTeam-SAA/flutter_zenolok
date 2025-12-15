import 'package:get/get.dart';
import '../../features/auth/presentation/controller/auth_controller.dart';
import '../../features/auth/presentation/controller/splash_screen_controller.dart';

void setupController() {
  // Auth Controller
  Get.lazyPut<AuthController>(() => AuthController(Get.find(), Get.find()));

  // Splash Controller (lazy load - will be initialized when splash screen opens)
  Get.lazyPut<SplashController>(() => SplashController());
}
