import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_zenolok/core/network/api_client.dart';
import 'package:flutter_zenolok/core/network/constants/api_constants.dart';
import 'package:flutter_zenolok/core/network/models/network_failure.dart';
import 'package:flutter_zenolok/core/network/models/network_success.dart';

import '../../domain/repositories/todo_item_repository.dart';
import '../models/todo_item_model.dart';
import '../models/todo_item_response.dart';

class TodoItemRepositoryImpl implements TodoItemRepository {
  final ApiClient _apiClient;

  TodoItemRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Either<NetworkFailure, NetworkSuccess<TodoItem>>> createTodoItem({
    required String categoryId,
    required String text,
  }) async {
    try {
      if (kDebugMode) {
        print('🚀 Repository: Creating todo item under category: $categoryId');
        print('   Text: $text');
      }

      final result = await _apiClient.post<TodoItemResponse>(
        ApiConstants.todoItems.createTodoItem,
        fromJsonT: (json) => TodoItemResponse.fromJson(json as Map<String, dynamic>),
        data: {
          'categoryId': categoryId,
          'text': text,
        },
      );

      return result.fold(
        (failure) {
          if (kDebugMode) {
            print('❌ Repository: Create todo item failed - ${failure.message}');
          }
          return Left(failure);
        },
        (success) {
          if (kDebugMode) {
            print('✅ Repository: Todo item created - ${success.data.data.text}');
            print('   ID: ${success.data.data.id}');
            print('   Category ID: ${success.data.data.categoryId}');
          }
          return Right(
            NetworkSuccess<TodoItem>(
              data: success.data.data,
              message: success.message,
              statusCode: success.statusCode,
            ),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Repository Exception: $e');
        print('   Stack trace: ${StackTrace.current}');
      }
      return Left(
        ServerFailure(
          message: 'Failed to create todo item: $e',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<NetworkFailure, NetworkSuccess<List<TodoItem>>>> getTodoItemsByCategory({
    required String categoryId,
  }) async {
    try {
      if (kDebugMode) {
        print('🔄 Repository: Fetching todo items for category: $categoryId');
        print('   Endpoint: ${ApiConstants.todoItems.byCategory(categoryId)}');
      }

      final result = await _apiClient.get<List<TodoItem>>(
        ApiConstants.todoItems.byCategory(categoryId),
        fromJsonT: (json) {
          if (kDebugMode) {
            print('📦 Repository fromJsonT: received type ${json.runtimeType}');
            print('   Value: $json');
          }

          if (json is List) {
            if (kDebugMode) {
              print('   ✅ Parsing as List with ${json.length} items');
            }
            return json
                .map((item) {
                  if (kDebugMode) {
                    print('   Parsing item: $item');
                  }
                  return TodoItem.fromJson(item as Map<String, dynamic>);
                })
                .toList();
          }

          if (kDebugMode) {
            print('   ❌ Not a List! Type: ${json.runtimeType}');
          }

          return <TodoItem>[];
        },
      );

      if (kDebugMode) {
        print('✅ Repository: Result received');
      }

      return result.fold(
        (failure) {
          if (kDebugMode) {
            print('❌ Repository: Fetch failed - ${failure.message}');
          }
          return Left(failure);
        },
        (success) {
          if (kDebugMode) {
            print('✅ Repository: Success with ${success.data.length} todos');
            for (int i = 0; i < success.data.length; i++) {
              print('   ${i + 1}. ${success.data[i].text}');
            }
          }
          return Right(
            NetworkSuccess<List<TodoItem>>(
              data: success.data,
              message: success.message,
              statusCode: success.statusCode,
            ),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Repository Exception: $e');
        print('   Stack trace: ${StackTrace.current}');
      }
      return Left(
        ServerFailure(
          message: 'Failed to fetch todo items: $e',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<NetworkFailure, NetworkSuccess<TodoItem>>> updateTodoItem({
    required String todoItemId,
    required bool isCompleted,
  }) async {
    try {
      if (kDebugMode) {
        print('🔄 Repository: Updating todo item: $todoItemId');
      }

      final result = await _apiClient.patch<TodoItemResponse>(
        ApiConstants.todoItems.updateTodoItem(todoItemId),
        fromJsonT: (json) => TodoItemResponse.fromJson(json as Map<String, dynamic>),
        data: {
          'isCompleted': isCompleted,
        },
      );

      return result.fold(
        (failure) {
          if (kDebugMode) {
            print('❌ Repository: Update failed - ${failure.message}');
          }
          return Left(failure);
        },
        (success) {
          if (kDebugMode) {
            print('✅ Repository: Todo item updated - ${success.data.data.text}');
          }
          return Right(
            NetworkSuccess<TodoItem>(
              data: success.data.data,
              message: success.message,
              statusCode: success.statusCode,
            ),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Repository Exception: $e');
      }
      return Left(
        ServerFailure(
          message: 'Failed to update todo item: $e',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<NetworkFailure, NetworkSuccess<void>>> deleteTodoItem({
    required String todoItemId,
  }) async {
    try {
      if (kDebugMode) {
        print('🗑️  Repository: Deleting todo item: $todoItemId');
      }

      final result = await _apiClient.delete<void>(
        ApiConstants.todoItems.deleteTodoItem(todoItemId),
        fromJsonT: (json) => null,
      );

      return result.fold(
        (failure) {
          if (kDebugMode) {
            print('❌ Repository: Delete failed - ${failure.message}');
          }
          return Left(failure);
        },
        (success) {
          if (kDebugMode) {
            print('✅ Repository: Todo item deleted');
          }
          return Right(
            NetworkSuccess<void>(
              data: null,
              message: success.message,
              statusCode: success.statusCode,
            ),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Repository Exception: $e');
      }
      return Left(
        ServerFailure(
          message: 'Failed to delete todo item: $e',
          statusCode: 500,
        ),
      );
    }
  }
}
