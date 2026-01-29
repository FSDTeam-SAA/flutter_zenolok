import 'package:flutter/foundation.dart';
import 'package:flutter_zenolok/features/todos/data/models/scheduled_todo_item_model.dart';
import 'package:flutter_zenolok/features/todos/domain/repositories/todo_category_repository.dart';
import 'package:flutter_zenolok/features/todos/domain/repositories/todo_item_repository.dart';
import 'package:get/get.dart';

import '../../data/models/category_model.dart';

class EventTodosController extends GetxController {
  final TodoCategoryRepository _categoryRepository;
  final TodoItemRepository _todoItemRepository;

  // Observable list for categories
  final categories = <CategoryModel>[].obs;
  final scheduledTodos = <ScheduledTodoItem>[].obs;
  final isLoading = false.obs;
  final isLoadingScheduled = false.obs;
  final errorMessage = ''.obs;
  final isCreating = false.obs;
  final isDeleting = false.obs;

  EventTodosController({
    required TodoCategoryRepository categoryRepository,
    required TodoItemRepository todoItemRepository,
  }) : _categoryRepository = categoryRepository,
       _todoItemRepository = todoItemRepository;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchScheduledTodos();
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
        // Check if the response has valid data
        final categoryData = success.data;

        if (kDebugMode) {
          print('✅ Category creation response received');
          print('📝 Category Data:');
          print('  ID: ${categoryData.id}');
          print('  Name: ${categoryData.name}');
          print('  Color: ${categoryData.color}');
          print('  ID is empty: ${categoryData.id.isEmpty}');
          print('  Name is empty: ${categoryData.name.isEmpty}');
        }

        // If we have valid name, add it to the list
        if (categoryData.name.isNotEmpty) {
          categories.add(categoryData);

          if (kDebugMode) {
            print('✅ Category added to list');
            print('📊 Total categories now: ${categories.length}');
          }
        } else {
          // If the response doesn't have complete data, refresh from server
          if (kDebugMode) {
            print('⚠️  Response incomplete, refreshing categories from server');
          }
          refreshCategories();
        }

        return true;
      },
    );
  }

  /// Refresh categories
  Future<void> refreshCategories() async {
    if (kDebugMode) {
      print('🔄 Refreshing categories from server...');
    }
    await fetchCategories();

    if (kDebugMode) {
      print('✅ Categories refreshed');
      print('   Total categories now: ${categories.length}');
      for (var i = 0; i < categories.length; i++) {
        final cat = categories[i];
        print('   [$i] ${cat.name} (ID: ${cat.id})');
      }
    }
  }

  /// Creates a new todo item under a category
  Future<bool> createTodoItem({
    required String categoryId,
    required String text,
  }) async {
    isCreating.value = true;
    errorMessage.value = '';

    // Validate categoryId
    if (categoryId.isEmpty) {
      errorMessage.value = 'Category ID is empty. Cannot create todo.';
      isCreating.value = false;
      if (kDebugMode) {
        print('❌ Controller: Cannot create todo - Category ID is empty!');
      }
      return false;
    }

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
            print(
              '  ${i + 1}. ${success.data[i].text} (Completed: ${success.data[i].isCompleted})',
            );
          }
        }

        // Convert TodoItem to Map<String, dynamic> for dialog
        final mappedTodos = success.data
            .map(
              (todo) => {
                'id': todo.id,
                'title': todo.text,
                'checked': todo.isCompleted,
              },
            )
            .toList();

        if (kDebugMode) {
          print(
            '🎯 Controller: Converted to Map, count: ${mappedTodos.length}',
          );
          for (int i = 0; i < mappedTodos.length; i++) {
            print('   ${i + 1}. ${mappedTodos[i]['title']}');
          }
        }

        return mappedTodos;
      },
    );
  }

  /// Fetches scheduled todo items from the API
  Future<void> fetchScheduledTodos() async {
    isLoadingScheduled.value = true;
    errorMessage.value = '';

    if (kDebugMode) {
      print('🔄 Controller: Fetching scheduled todo items from API...');
    }

    final result = await _todoItemRepository.getScheduledTodoItems();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        scheduledTodos.clear();
        if (kDebugMode) {
          print(
            '❌ Controller: Error fetching scheduled todos: ${failure.message}',
          );
        }
      },
      (success) {
        scheduledTodos.value = success.data;
        errorMessage.value = '';

        if (kDebugMode) {
          print('✅ Controller: Scheduled todos fetched successfully!');
          print('📊 Total scheduled todos: ${success.data.length}');
          print('─' * 50);
          for (int i = 0; i < success.data.length; i++) {
            final todo = success.data[i];
            print('Scheduled Todo ${i + 1}:');
            print('  ID: ${todo.id}');
            print('  Text: ${todo.text}');
            print('  Category: ${todo.categoryId?.name ?? "No Category"}');
            print('  Section: ${todo.sectionLabel}');
            print('  Completed: ${todo.isCompleted}');
            print('─' * 50);
          }
        }
      },
    );

    isLoadingScheduled.value = false;
  }

  /// Refresh scheduled todos
  Future<void> refreshScheduledTodos() async {
    if (kDebugMode) {
      print('🔄 Controller: Refreshing scheduled todos from server...');
    }
    await fetchScheduledTodos();

    if (kDebugMode) {
      print('✅ Controller: Scheduled todos refreshed');
      print('   Total todos now: ${scheduledTodos.length}');
      for (var i = 0; i < scheduledTodos.length; i++) {
        final todo = scheduledTodos[i];
        print('   [$i] ${todo.text} (${todo.sectionLabel})');
      }
    }
  }

  /// Updates an existing category
  Future<bool> updateCategory({
    required String categoryId,
    required String name,
    required String color,
  }) async {
    isCreating.value = true;
    errorMessage.value = '';

    if (kDebugMode) {
      print('🚀 Updating category: $name with color $color');
      print('   Category ID: $categoryId');
    }

    final result = await _categoryRepository.updateCategory(
      categoryId: categoryId,
      name: name,
      color: color,
    );

    isCreating.value = false;

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        if (kDebugMode) {
          print('❌ Error updating category: ${failure.message}');
        }
        return false;
      },
      (success) {
        // Update the category in the list
        final index = categories.indexWhere((cat) => cat.id == categoryId);
        if (index != -1) {
          categories[index] = success.data;
          categories.refresh();

          if (kDebugMode) {
            print('✅ Category updated successfully!');
            print('📝 Updated Category:');
            print('  ID: ${success.data.id}');
            print('  Name: ${success.data.name}');
            print('  Color: ${success.data.color}');
          }
        }

        return true;
      },
    );
  }

  /// Get filtered scheduled todos by category
  List<ScheduledTodoItem> getFilteredScheduledTodos({
    required String categoryFilter,
    required String statusFilter,
  }) {
    var filtered = scheduledTodos.toList();

    // Filter by category
    if (categoryFilter != 'All') {
      filtered = filtered
          .where((todo) => todo.categoryId?.name == categoryFilter)
          .toList();
    }

    // Filter by completion status
    if (statusFilter == 'Finished') {
      filtered = filtered.where((todo) => todo.isCompleted).toList();
    } else if (statusFilter == 'Unfinished') {
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
    }
    // 'All' status shows all items

    return filtered;
  }

  /// Get unique categories from scheduled todos
  List<String> getScheduledCategories() {
    final categories = <String>{'All'};
    for (var todo in scheduledTodos) {
      if (todo.categoryId?.name != null) {
        categories.add(todo.categoryId!.name);
      }
    }
    return categories.toList();
  }

  /// Get color for a category
  String? getCategoryColor(String categoryName) {
    for (var todo in scheduledTodos) {
      if (todo.categoryId?.name == categoryName) {
        return todo.categoryId?.color;
      }
    }
    return null;
  }

  /// Deletes a category
  Future<bool> deleteCategory({required String categoryId}) async {
    isDeleting.value = true;
    errorMessage.value = '';

    if (kDebugMode) {
      print('🗑️ Deleting category: $categoryId');
    }

    final result = await _categoryRepository.deleteCategory(
      categoryId: categoryId,
    );

    isDeleting.value = false;

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        if (kDebugMode) {
          print('❌ Error deleting category: ${failure.message}');
        }
        return false;
      },
      (success) {
        // Remove the category from the list
        categories.removeWhere((category) => category.id == categoryId);

        if (kDebugMode) {
          print('✅ Category deleted successfully!');
          print('📊 Total categories now: ${categories.length}');
        }

        return true;
      },
    );
  }

  /// Deletes a todo item
  Future<bool> deleteTodoItem({required String todoItemId}) async {
    errorMessage.value = '';

    if (kDebugMode) {
      print('🗑️ Deleting todo item: $todoItemId');
    }

    final result = await _todoItemRepository.deleteTodoItem(
      todoItemId: todoItemId,
    );

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        if (kDebugMode) {
          print('❌ Error deleting todo item: ${failure.message}');
        }
        return false;
      },
      (success) {
        if (kDebugMode) {
          print('✅ Todo item deleted successfully!');
        }
        return true;
      },
    );
  }
}
