import 'package:dartz/dartz.dart';
import 'package:flutter_zenolok/core/network/models/network_failure.dart';
import 'package:flutter_zenolok/core/network/models/network_success.dart';
import '../../data/models/category_model.dart';

abstract class TodoCategoryRepository {
  /// Fetches all todo categories
  /// Returns either a [NetworkFailure] or a list of [CategoryModel]
  Future<Either<NetworkFailure, NetworkSuccess<List<CategoryModel>>>>
  getAllCategories();

  /// Creates a new todo category
  /// Returns either a [NetworkFailure] or the created [CategoryModel]
  Future<Either<NetworkFailure, NetworkSuccess<CategoryModel>>> createCategory({
    required String name,
    required String color,
  });

  /// Updates an existing todo category
  /// Returns either a [NetworkFailure] or the updated [CategoryModel]
  Future<Either<NetworkFailure, NetworkSuccess<CategoryModel>>> updateCategory({
    required String categoryId,
    required String name,
    required String color,
  });

  /// Deletes a todo category
  /// Returns either a [NetworkFailure] or a success message
  Future<Either<NetworkFailure, NetworkSuccess<void>>> deleteCategory({
    required String categoryId,
  });
}
