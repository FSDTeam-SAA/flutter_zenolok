import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/network/models/network_failure.dart';
import '../../../../core/network/models/network_success.dart';

import '../../data/models/brick_model.dart';
import '../../data/models/category_design.dart';
import '../../data/models/create_brick_request_model.dart';
import '../../data/models/update_brick_request_model.dart';
import '../../domain/repo/brick_repo.dart';

class BrickController extends GetxController {
  BrickController({required BrickRepository repository})
    : _repository = repository;

  final BrickRepository _repository;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  late final RxList<BrickModel> bricks = <BrickModel>[].obs;

  void resetDesign() {
    design.value = const CategoryDesign(
      color: null,
      icon: Icons.work_outline,
      iconKey: 'ri-focus-2-fill',
      name: '',
    );
    errorMessage.value = null;
  }






  /// ✅ Editor state (start grey)
  final Rx<CategoryDesign> design = const CategoryDesign(
    color: null,
    icon: Icons.work_outline,
    iconKey: 'ri-focus-2-fill',
    name: '',
  ).obs;

  bool get hasColor => design.value.color != null;

  void updateDesign(CategoryDesign d) {
    design.value = d;
  }

  /// Flutter Color -> "#RRGGBB"
  String _colorToHex(Color color) {
    final value = color.value.toRadixString(16).padLeft(8, '0'); // AARRGGBB
    return '#${value.substring(2).toUpperCase()}'; // RRGGBB
  }

  Future<BrickModel?> createBrick() async {
    final d = design.value;

    if (d.color == null) {
      errorMessage.value = 'Select a color before adding a brick.';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final request = CreateBrickRequestModel(
      name: d.name.trim().isEmpty ? 'Bricks' : d.name.trim(),
      color: _colorToHex(d.color!),
      icon: d.iconKey,
    );

    final Either<NetworkFailure, NetworkSuccess<BrickModel>> result =
    await _repository.createBrick(request);

    BrickModel? created;

    result.fold(
          (failure) => errorMessage.value = failure.message,
          (success) {
        created = success.data;

        bricks.add(success.data);
        bricks.refresh();

        resetDesign();
      },
    );

    isLoading.value = false;

    return created;
  }

  Future<void> loadBricks() async {
    isLoading.value = true;
    errorMessage.value = null;

    final Either<NetworkFailure, NetworkSuccess<List<BrickModel>>> result =
    await _repository.getBricks();

    result.fold(
          (failure) => errorMessage.value = failure.message,
          (success) {
        bricks.assignAll(success.data);
        bricks.refresh();
      },
    );

    isLoading.value = false;
  }

  Future<BrickModel?> updateBrick(String brickId) async {
    final d = design.value;

    if (d.color == null) {
      errorMessage.value = 'Select a color before updating the brick.';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final request = UpdateBrickRequestModel(
      name: d.name.trim().isEmpty ? 'Bricks' : d.name.trim(),
      color: _colorToHex(d.color!),
      icon: d.iconKey,
    );

    final Either<NetworkFailure, NetworkSuccess<BrickModel>> result =
    await _repository.updateBrick(brickId, request);

    BrickModel? updated;

    result.fold(
          (failure) => errorMessage.value = failure.message,
          (success) {
        updated = success.data;

        // Update the brick in the list
        final index = bricks.indexWhere((b) => b.id == brickId);
        if (index != -1) {
          bricks[index] = success.data;
          bricks.refresh();
        }

        resetDesign();
      },
    );

    isLoading.value = false;

    return updated;
  }
}
