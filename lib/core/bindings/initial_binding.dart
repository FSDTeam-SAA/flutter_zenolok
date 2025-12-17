import 'package:get/get.dart';

import '../../features/home/presentation/bindings/brick_binding.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    BrickBinding().dependencies();
  }
}
