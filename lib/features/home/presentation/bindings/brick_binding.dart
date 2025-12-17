import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repo/brick_repo_impl.dart';
import '../../domain/repo/brick_repo.dart';
import '../controller/brick_controller.dart';

class BrickBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient());
    Get.lazyPut<BrickRepository>(
          () => BrickRepositoryImpl(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<BrickController>(
          () => BrickController(repository: Get.find<BrickRepository>()),
    );
  }
}
