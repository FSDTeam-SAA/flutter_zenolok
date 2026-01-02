import 'package:get/get.dart';
import '../../features/auth/data/repo/auth_repo_impl.dart';
import '../../features/auth/domain/repo/auth_repo.dart';
import '../../features/todos/data/repositories/todo_category_repository_impl.dart';
import '../../features/todos/domain/repositories/todo_category_repository.dart';
import '../../features/todos/data/repositories/todo_item_repository_impl.dart';
import '../../features/todos/domain/repositories/todo_item_repository.dart';


void setupRepository() {
  Get.lazyPut<AuthRepository>(
    fenix: true,
    () => AuthRepositoryImpl(apiClient: Get.find()),
  );

  Get.lazyPut<TodoCategoryRepository>(
    fenix: true,
    () => TodoCategoryRepositoryImpl(apiClient: Get.find()),
  );

  Get.lazyPut<TodoItemRepository>(
    fenix: true,
    () => TodoItemRepositoryImpl(apiClient: Get.find()),
  );
}
