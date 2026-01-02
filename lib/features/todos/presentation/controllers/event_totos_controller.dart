import 'package:flutter/foundation.dart';
import 'package:flutter_zenolok/features/todos/domain/repositories/todo_category_repository.dart';
import 'package:flutter_zenolok/features/todos/domain/repositories/todo_item_repository.dart';
import 'package:get/get.dart';

import '../../data/models/category_model.dart';

class EventTodosController extends GetxController {
  final TodoCategoryRepository _categoryRepository;
  final TodoItemRepository _todoItemRepository;

  // Observable list for categories
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isCreating = false.obs;

  EventTodosController({
    required TodoCategoryRepository categoryRepository,
    required TodoItemRepository todoItemRepository,
  })  : _categoryRepository = categoryRepository,
        _todoItemRepository = todoItemRepository;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  /// Fetches all categories from the API
  Future<void> fetchCategories() async {
    isLoading.value = true;
    errorMessage.value = '';

    if (kDebugMode) {
      print('🔄 Fetching categories from API...');
    }

    final result = await _categoryRepository.getAllCategories();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        categories.clear();
        if (kDebugMode) {
          print('❌ Error fetching categories: ${failure.message}');
        }
      },
      (success) {
        categories.value = success.data;
        errorMessage.value = '';
        
        if (kDebugMode) {
          print('✅ Categories fetched successfully!');
          print('📊 Total categories: ${success.data.length}');
          print('─' * 50);
          for (int i = 0; i < success.data.length; i++) {
            final cat = success.data[i];
            print('Category ${i + 1}:');
            print('  ID: ${cat.id}');
            print('  Name: ${cat.name}');
            print('  Color: ${cat.color}');
            print('  Created By: ${cat.createdBy}');
            print('  Participants: ${cat.participants.length}');
            print('  Created At: ${cat.createdAt}');
            print('  Updated At: ${cat.updatedAt}');
            print('─' * 50);
          }
        }
      },
    );

    isLoading.value = false;
  }

  /// Creates a new category
  Future<bool> createCategory({
    required String name,
    required String color,
  }) async {
    isCreating.value = true;
    errorMessage.value = '';

    if (kDebugMode) {
      print('🚀 Creating new category: $name with color $color');
    }

    final result = await _categoryRepository.createCategory(
      name: name,
      color: color,
    );

    isCreating.value = false;

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        if (kDebugMode) {
          print('❌ Error creating category: ${failure.message}');
        }
        return false;
      },
      (success) {
        // Add the new category to the list
        categories.add(success.data);
        
        if (kDebugMode) {
          print('✅ Category created successfully!');
          print('📝 New Category:');
          print('  ID: ${success.data.id}');
          print('  Name: ${success.data.name}');
          print('  Color: ${success.data.color}');
          print('  Created At: ${success.data.createdAt}');
          print('─' * 50);
          print('📊 Total categories now: ${categories.length}');
        }

        return true;
      },
    );
  }

  /// Refresh categories
  Future<void> refreshCategories() async {
    if (kDebugMode) {
      print('🔄 Refreshing categories...');
    }
    await fetchCategories();
  }

  /// Creates a new todo item under a category
  Future<bool> createTodoItem({
    required String categoryId,
    required String text,
  }) async {
    isCreating.value = true;
    errorMessage.value = '';

    if (kDebugMode) {
      print('🚀 Creating new todo item: $text');
      print('   Category ID: $categoryId');
    }

    final result = await _todoItemRepository.createTodoItem(
      categoryId: categoryId,
      text: text,
    );

    isCreating.value = false;

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        if (kDebugMode) {
          print('❌ Error creating todo item: ${failure.message}');
        }
        return false;
      },
      (success) {
        if (kDebugMode) {
          print('✅ Todo item created successfully!');
          print('📝 New Todo:');
          print('  ID: ${success.data.id}');
          print('  Text: ${success.data.text}');
          print('  Category ID: ${success.data.categoryId}');
          print('  Created At: ${success.data.createdAt}');
          print('─' * 50);
        }
        return true;
      },
    );
  }

  /// Fetches todo items for a specific category
  Future<List<Map<String, dynamic>>> fetchTodoItemsByCategory({
    required String categoryId,
  }) async {
    if (kDebugMode) {
      print('🔄 Controller: Fetching todo items for category: $categoryId');
    }

    final result = await _todoItemRepository.getTodoItemsByCategory(
      categoryId: categoryId,
    );

    return result.fold(
      (failure) {
        if (kDebugMode) {
          print('❌ Controller: Error fetching todo items: ${failure.message}');
        }
        return <Map<String, dynamic>>[];
      },
      (success) {
        if (kDebugMode) {
          print('✅ Controller: Todo items fetched successfully!');
          print('📊 Total todos: ${success.data.length}');
          for (int i = 0; i < success.data.length; i++) {
            print('  ${i + 1}. ${success.data[i].text} (Completed: ${success.data[i].isCompleted})');
          }
        }
        
        // Convert TodoItem to Map<String, dynamic> for dialog
        final mappedTodos = success.data
            .map((todo) => {
                  'id': todo.id,
                  'title': todo.text,
                  'checked': todo.isCompleted,
                })
            .toList();

        if (kDebugMode) {
          print('🎯 Controller: Converted to Map, count: ${mappedTodos.length}');
          for (int i = 0; i < mappedTodos.length; i++) {
            print('   ${i + 1}. ${mappedTodos[i]['title']}');
          }
        }

        return mappedTodos;
      },
    );
  }
}
