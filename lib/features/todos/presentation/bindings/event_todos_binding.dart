import 'package:get/get.dart';
import '../controllers/event_totos_controller.dart';

class EventTodosBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<EventTodosController>(
      EventTodosController(
        categoryRepository: Get.find(),
        todoItemRepository: Get.find(),
      ),
    );
  }
}
