import '../../../../core/network/network_result.dart';
import '../../data/models/brick_model.dart';
import '../../data/models/create_brick_request_model.dart';
import '../../data/models/update_brick_request_model.dart';

abstract class BrickRepository {
  /// POST /bricks
  NetworkResult<BrickModel> createBrick(CreateBrickRequestModel request);

  /// GET /bricks
  NetworkResult<List<BrickModel>> getBricks();

  /// GET /bricks/:id
  NetworkResult<BrickModel> getBrickById(String id);

  /// PATCH /bricks/:id
  NetworkResult<BrickModel> updateBrick(
      String id,
      UpdateBrickRequestModel request,
      );

  /// DELETE /bricks/:id
  NetworkResult<void> deleteBrick(String id);
}
