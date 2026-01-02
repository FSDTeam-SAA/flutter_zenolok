import 'package:dartz/dartz.dart';
import 'package:flutter_zenolok/core/network/models/network_failure.dart';
import 'package:flutter_zenolok/core/network/models/network_success.dart';

import '../../data/models/todo_item_model.dart';

abstract class TodoItemRepository {
  /// Create a new todo item under a category
  Future<Either<NetworkFailure, NetworkSuccess<TodoItem>>> createTodoItem({
    required String categoryId,
    required String text,
  });

  /// Get todo items by category
  Future<Either<NetworkFailure, NetworkSuccess<List<TodoItem>>>> getTodoItemsByCategory({
    required String categoryId,
  });

  /// Update todo item
  Future<Either<NetworkFailure, NetworkSuccess<TodoItem>>> updateTodoItem({
    required String todoItemId,
    required bool isCompleted,
  });

  /// Delete todo item
  Future<Either<NetworkFailure, NetworkSuccess<void>>> deleteTodoItem({
    required String todoItemId,
  });
}
