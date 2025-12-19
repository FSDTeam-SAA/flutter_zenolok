import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repo/brick_repo_impl.dart';
import '../../domain/repo/brick_repo.dart';
import '../controller/brick_controller.dart';

class BrickBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Only register if not already registered
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    Get.lazyPut<BrickRepository>(
          () => BrickRepositoryImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<BrickController>(
          () => BrickController(repository: Get.find<BrickRepository>()),
      fenix: true,
    );
  }
}
