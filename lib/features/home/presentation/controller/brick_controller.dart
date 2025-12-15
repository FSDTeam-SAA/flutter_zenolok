import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter_zenolok/core/network/api_client.dart';
import 'package:flutter_zenolok/core/network/models/network_failure.dart';
import 'package:flutter_zenolok/core/network/models/network_success.dart';

import '../../data/models/brick_model.dart';
import '../../data/models/create_brick_request_model.dart';
import '../../domain/repo/brick_repo.dart';
import '../../data/repo/brick_repo_impl.dart';
import '../widgets/cateogry_widget.dart';

class BrickController extends ChangeNotifier {
  final BrickRepository _repository;

  /// If you don’t inject a repo, we create a default BrickRepositoryImpl
  BrickController({BrickRepository? repository})
      : _repository = repository ?? BrickRepositoryImpl(apiClient: ApiClient());

  bool isLoading = false;
  String? errorMessage;
  List<BrickModel> bricks = [];

  CategoryDesign _currentDesign = const CategoryDesign(
    color: null,
    icon: Icons.work_outline,
    name: 'Bricks',
  );

  CategoryDesign get currentDesign => _currentDesign;

  void updateDesign(CategoryDesign design) {
    _currentDesign = design;
    notifyListeners();
  }

  /// Helper: convert Flutter Color to "#RRGGBB"
  String _colorToHex(Color color) {
    final value = color.value.toRadixString(16).padLeft(8, '0'); // AARRGGBB
    // drop alpha, keep RRGGBB
    return '#${value.substring(2).toUpperCase()}';
  }

  /// Map IconData to backend icon key (adjust these to match your backend)
  String _iconToBackendKey(IconData icon) {
    if (icon == Icons.work_outline) return 'ri-focus-2-fill';
    if (icon == Icons.home_outlined) return 'ri-home-4-line';
    if (icon == Icons.school_outlined) return 'ri-book-3-line';
    // fallback
    return 'ri-focus-2-fill';
  }

  Future<void> createBrick() async {
    if (_currentDesign.color == null) {
      errorMessage = 'Select a color before adding a brick.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final colorHex = _colorToHex(_currentDesign.color!);
    final iconKey = _iconToBackendKey(_currentDesign.icon);

    final request = CreateBrickRequestModel(
      name: _currentDesign.name.trim().isEmpty
          ? 'Untitled'
          : _currentDesign.name.trim(),
      color: colorHex,
      icon: iconKey,
    );

    // NetworkResult<T> == Future<Either<NetworkFailure, NetworkSuccess<T>>>
    final Either<NetworkFailure, NetworkSuccess<BrickModel>> result =
    await _repository.createBrick(request);

    result.fold(
          (failure) {
        errorMessage = failure.message;
      },
          (success) {
        bricks.add(success.data);
        errorMessage = null;
      },
    );

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadBricks() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final Either<NetworkFailure, NetworkSuccess<List<BrickModel>>> result =
    await _repository.getBricks();

    result.fold(
          (failure) => errorMessage = failure.message,
          (success) => bricks = success.data,
    );

    isLoading = false;
    notifyListeners();
  }
}
