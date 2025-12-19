import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repo/event_repo_impl.dart';
import '../../domain/repo/event_repo.dart';
import '../../presentation/controller/event_controller.dart';

class EventBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ ensure ApiClient exists (shared with BrickBinding)
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    Get.lazyPut<EventRepo>(
          () => EventRepoImpl(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<EventController>(
          () => EventController(Get.find<EventRepo>()),
      fenix: true,
    );
  }
}
