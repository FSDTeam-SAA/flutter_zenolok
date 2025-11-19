import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../../domain/repo/auth_repo.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/otp_request_model.dart';
import '../models/otp_response_model.dart';
import '../models/refresh_token_request_model.dart';
import '../models/refresh_token_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/reset_password_response_model.dart';
import '../models/set_new_password_request_model.dart';
import '../models/set_new_password_response_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  NetworkResult<AuthResponseData> login(LoginRequestModel request) {
    return _apiClient.post<AuthResponseData>(
      ApiConstants.auth.login,
      data: request.toJson(),
      fromJsonT: (json) => AuthResponseData.fromJson(json),
      // isFormData: true
    );
  }


  @override
  NetworkResult<ResetPasswordResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) {
    return _apiClient.post(
      ApiConstants.auth.resetPass,
      data: request.toJson(),
      fromJsonT: (json) => ResetPasswordResponseModel.fromJson(json),
    );
  }

  @override
  NetworkResult<OtpVerificationResponseModel> otpVerify(
    OtpVerificationRequestModel request,
  ) {
    return _apiClient.post(
      ApiConstants.auth.otpVerify,
      data: request.toJson(),
      fromJsonT: (json) => OtpVerificationResponseModel.fromJson(json),
    );
  }


  @override
  NetworkResult<SetNewPasswordResponseModel> setNewPassword(
    SetNewPasswordRequestModel request,
  ) {
    return _apiClient.post(
      ApiConstants.auth.setNewPass,
      data: request.toJson(),
      fromJsonT: (json) => SetNewPasswordResponseModel.fromJson(json),
    );
  }

  @override
  NetworkResult<RefreshTokenResponseModel> refreshToken(
    RefreshTokenRequestModel request,
  ) {
    return _apiClient.post(
      ApiConstants.auth.refreshToken,
      data: request.toJson(),
      fromJsonT: (json) => RefreshTokenResponseModel.fromJson(json),
    );
  }

  @override
  NetworkResult<UserModel> getUserProfile() {
    return _apiClient.get<UserModel>(
      ApiConstants.user.getUserProfile,
      fromJsonT: (json) => UserModel.fromJson(json),
    );
  }
}
