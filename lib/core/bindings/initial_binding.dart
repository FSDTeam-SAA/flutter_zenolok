import 'package:get/get.dart';

import '../../features/home/presentation/bindings/brick_binding.dart';
import '../../features/home/presentation/bindings/event_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    BrickBinding().dependencies();
    EventBinding().dependencies();
  }
}
