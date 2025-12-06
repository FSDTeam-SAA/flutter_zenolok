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
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/verify_account_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  NetworkResult<AuthResponseData> login(LoginRequestModel request) {
    return _apiClient.post<AuthResponseData>(
      ApiConstants.auth.login,
      data: request.toJson(),
      fromJsonT: (json) => AuthResponseData.fromJson(json),
    );
  }

  @override
  NetworkResult<RegisterResponseModel> register(RegisterRequestModel request) {
    return _apiClient.post<RegisterResponseModel>(
      ApiConstants.auth.register,
      data: request.toJson(),
      fromJsonT: (json) => RegisterResponseModel.fromJson(json),
    );
  }

  @override
  NetworkResult<void> verifyAccount(VerifyAccountRequestModel request) {
    return _apiClient.post<void>(
      ApiConstants.auth.otpVerifyRegister,
      data: request.toJson(),
      fromJsonT: (json) {},
    );
  }


  @override
  NetworkResult<void> resetPassword(
    ResetPasswordRequestModel request,
  ) {
    return _apiClient.post(
      ApiConstants.auth.resetPass,
      data: request.toJson(),
      fromJsonT: (json) {},
    );
  }

  @override
  NetworkResult<void> otpVerify(
    OtpVerificationRequestModel request,
  ) {
    return _apiClient.post(
      ApiConstants.auth.otpVerify,
      data: request.toJson(),
      fromJsonT: (json) {},
    );
  }


  @override
  NetworkResult<void> setNewPassword(
    SetNewPasswordRequestModel request,
  ) {
    return _apiClient.post(
      ApiConstants.auth.setNewPass,
      data: request.toJson(),
      fromJsonT: (json) {},
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
