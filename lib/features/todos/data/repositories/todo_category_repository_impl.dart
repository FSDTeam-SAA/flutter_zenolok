import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_zenolok/core/network/api_client.dart';
import 'package:flutter_zenolok/core/network/constants/api_constants.dart';
import 'package:flutter_zenolok/core/network/models/network_failure.dart';
import 'package:flutter_zenolok/core/network/models/network_success.dart';

import '../../domain/repositories/todo_category_repository.dart';
import '../models/category_model.dart';
import '../models/create_category_response.dart';

class TodoCategoryRepositoryImpl implements TodoCategoryRepository {
  final ApiClient _apiClient;

  TodoCategoryRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Either<NetworkFailure, NetworkSuccess<List<CategoryModel>>>>
      getAllCategories() async {
    try {
      if (kDebugMode) {
        print('🔄 Repository: Fetching categories');
      }

      final result = await _apiClient.get<List<CategoryModel>>(
        ApiConstants.todoCategories.getAllCategories,
        fromJsonT: (json) {
          if (kDebugMode) {
            print('📦 Repository: fromJsonT received: ${json.runtimeType}');
            if (json is List) {
              print('   List length: ${json.length}');
            }
          }

          // Handle List<dynamic> from API response's data field
          if (json is List) {
            return json
                .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }

          // Fallback if somehow we get a Map
          if (json is Map<String, dynamic>) {
            final dataList = json['data'] as List<dynamic>? ?? [];
            return dataList
                .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }

          if (kDebugMode) {
            print('❌ Repository: Unexpected type: ${json.runtimeType}');
          }

          return <CategoryModel>[];
        },
      );

      if (kDebugMode) {
        print('✅ Repository: Result received');
      }

      return result.fold(
        (failure) {
          if (kDebugMode) {
            print('❌ Repository: Failure - ${failure.message}');
          }
          return Left(failure);
        },
        (success) {
          if (kDebugMode) {
            print('✅ Repository: Success with ${success.data.length} categories');
            for (int i = 0; i < success.data.length; i++) {
              print('   ${i + 1}. ${success.data[i].name}');
            }
          }

          return Right(
            NetworkSuccess<List<CategoryModel>>(
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
          message: 'Failed to fetch categories: $e',
          statusCode: 500,
        ),
      );
    }
  }

  @override
  Future<Either<NetworkFailure, NetworkSuccess<CategoryModel>>> createCategory({
    required String name,
    required String color,
  }) async {
    try {
      if (kDebugMode) {
        print('🚀 Repository: Creating category');
        print('   Name: "$name"');
        print('   Color: "$color"');
        print('   Endpoint: ${ApiConstants.todoCategories.createCategory}');
        print('   Request Body: {"name": "$name", "color": "$color"}');
      }

      final result = await _apiClient.post<CreateCategoryResponse>(
        ApiConstants.todoCategories.createCategory,
        fromJsonT: (json) {
          if (kDebugMode) {
            print('📦 Repository: Raw JSON received from API:');
            print('   $json');
          }
          return CreateCategoryResponse.fromJson(json as Map<String, dynamic>);
        },
        data: {
          'name': name,
          'color': color,
        },
      );

      return result.fold(
        (failure) {
          if (kDebugMode) {
            print('❌ Repository: Create failed');
            print('   Error: ${failure.message}');
          }
          return Left(failure);
        },
        (success) {
          if (kDebugMode) {
            print('✅ Repository: Category creation response received');
            print('   Response Message: "${success.message}"');
            print('   Status Code: ${success.statusCode}');
            print('   Category Data:');
            print('     ID: "${success.data.data.id}"');
            print('     Name: "${success.data.data.name}"');
            print('     CreatedBy: "${success.data.data.createdBy}"');
            print('     Color: "${success.data.data.color}"');
            print('   ID is empty: ${success.data.data.id.isEmpty}');
            print('   Name is empty: ${success.data.data.name.isEmpty}');
          }

          // Return the response data as-is, whether complete or incomplete
          // Let the controller handle incomplete responses
          
          return Right(
            NetworkSuccess<CategoryModel>(
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
          message: 'Failed to create category: $e',
          statusCode: 500,
        ),
      );
    }
  }
}
