import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../../domain/repo/brick_repo.dart';
import '../models/brick_model.dart';
import '../models/create_brick_request_model.dart';
import '../models/update_brick_request_model.dart';

class BrickRepositoryImpl implements BrickRepository {
  final ApiClient _apiClient;

  BrickRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  NetworkResult<BrickModel> createBrick(
      CreateBrickRequestModel request,
      ) {
    return _apiClient.post<BrickModel>(
      ApiConstants.bricks.base,
      data: request.toJson(),
      fromJsonT: (json) => BrickModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  NetworkResult<List<BrickModel>> getBricks() {
    return _apiClient.get<List<BrickModel>>(
      ApiConstants.bricks.base,
      fromJsonT: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => BrickModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  @override
  NetworkResult<BrickModel> getBrickById(String id) {
    return _apiClient.get<BrickModel>(
      ApiConstants.bricks.byId(id),
      fromJsonT: (json) => BrickModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  NetworkResult<BrickModel> updateBrick(
      String id,
      UpdateBrickRequestModel request,
      ) {
    return _apiClient.patch<BrickModel>(
      ApiConstants.bricks.byId(id),
      data: request.toJson(),
      fromJsonT: (json) => BrickModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  NetworkResult<void> deleteBrick(String id) {
    return _apiClient.delete<void>(
      ApiConstants.bricks.byId(id),
      fromJsonT: (json) {},
    );
  }
}
