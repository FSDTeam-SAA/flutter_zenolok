import '../../../../core/network/network_result.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/otp_request_model.dart';
import '../../data/models/otp_response_model.dart';
import '../../data/models/refresh_token_request_model.dart';
import '../../data/models/refresh_token_response_model.dart';
import '../../data/models/reset_password_request_model.dart';
import '../../data/models/reset_password_response_model.dart';
import '../../data/models/set_new_password_request_model.dart';
import '../../data/models/set_new_password_response_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/register_request_model.dart';
import '../../data/models/register_response_model.dart';
import '../../data/models/verify_account_request_model.dart';

abstract class AuthRepository {
  NetworkResult<AuthResponseData> login(LoginRequestModel request);
  NetworkResult<RegisterResponseModel> register(RegisterRequestModel request);
  NetworkResult<void> verifyAccount(VerifyAccountRequestModel request);

  NetworkResult<void> resetPassword(ResetPasswordRequestModel request);
  NetworkResult<void> otpVerify(OtpVerificationRequestModel request);
  NetworkResult<void> setNewPassword(SetNewPasswordRequestModel request);
  NetworkResult<RefreshTokenResponseModel> refreshToken(RefreshTokenRequestModel request);
  NetworkResult<UserModel> getUserProfile();
}
