import 'package:get/get.dart';
import '../../features/auth/data/repo/auth_repo_impl.dart';
import '../../features/auth/domain/repo/auth_repo.dart';


void setupRepository() {
  Get.lazyPut<AuthRepository>(
    fenix: true,
    () => AuthRepositoryImpl(apiClient: Get.find()),
  );
}
