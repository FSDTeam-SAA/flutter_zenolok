import 'package:flutx_core/flutx_core.dart';
import 'package:get/get.dart';
import '../../../../core/base/base_controller.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../../../core/services/get_user_profile_service.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/otp_request_model.dart';
import '../../data/models/refresh_token_request_model.dart';
import '../../data/models/reset_password_request_model.dart';
import '../../data/models/set_new_password_request_model.dart';
import '../../domain/repo/auth_repo.dart';
import '../screens/login_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/set_new_password_screen.dart';
import '../../data/models/register_request_model.dart';
import '../../data/models/verify_account_request_model.dart';
import '../screens/otp_verification_to_complete_register.dart';

class AuthController extends BaseController {
  final AuthRepository _authRepository;
  final AuthStorageService _authStorageService;
  bool _isSuccess = false;

  AuthController(this._authRepository, this._authStorageService);

  final userProfileService = Get.find<GetUserProfileService>();

  // Login
  Future<void> login(String email, String password) async {
    setLoading(true);
    setError("");

    final request = LoginRequestModel(email: email, password: password);

    final result = await _authRepository.login(request);

    result.fold(
      (fail) {
        setError(fail.message);
        setLoading(false);
      },
      (success) async {
        final user = success.data.user;
        if (user.role == 'manager') {
          await _authStorageService.storeAuthData(
            accessToken: success.data.accessToken,
            refreshToken: success.data.refreshToken,
            userId: success.data.user.id,
          );
          // TODO: Fetch user profile after login
        } else {
          setError(success.message);
        }
        setLoading(false);
      },
    );
  }

  Future<void> register(String name, String email, String password) async {
    setLoading(true);
    setError("");

    final request = RegisterRequestModel(
      name: name,
      email: email,
      password: password,
    );

    final result = await _authRepository.register(request);

    result.fold(
      (fail) {
        setError(fail.message);
        setLoading(false);
      },
      (success) {
        Get.to(() => OtpVerificationToCompleteRegister(email: email));
        setLoading(false);
      },
    );
  }

  Future<void> verifyAccount(String email, String otp) async {
    setLoading(true);
    setError("");

    final request = VerifyAccountRequestModel(email: email, otp: otp);

    final result = await _authRepository.verifyAccount(request);

    result.fold(
      (fail) {
        setError(fail.message);
        setLoading(false);
      },
      (success) {
        Get.offAll(() => LoginScreen());
        setLoading(false);
      },
    );
  }

  Future resetPass(String email) async {
    setLoading(true);
    setError('');

    final request = ResetPasswordRequestModel(email: email);
    final result = await _authRepository.resetPassword(request);

    result.fold(
      (fail) {
        setError(fail.message);
        DPrint.log("reset pass success result : ${fail.message}");
        setLoading(false);
      },
      (success) {
        DPrint.log("reset pass success result : ${success.data.message}");
        Get.to(OtpVerificationScreen(email: email));
        setLoading(false);
      },
    );
  }

  Future resendOTP(String email) async {
    setLoading(true);
    setError("");

    final request = ResetPasswordRequestModel(email: email);
    final result = await _authRepository.resetPassword(request);

    result.fold(
      (fail) {
        setError(fail.message);
        DPrint.log("reset pass success result : ${fail.message}");
        setLoading(false);
      },
      (success) {
        DPrint.log("reset pass success result : ${success.data.message}");
        Get.snackbar("OTP Sent", "We have resent the OTP to $email");
        setLoading(false);
      },
    );
  }

  Future verifyOTP(String email, String otp) async {
    setLoading(true);
    setError("");

    final request = OtpVerificationRequestModel(email: email, otp: otp);
    final result = await _authRepository.otpVerify(request);

    result.fold(
      (fail) {
        setError(fail.message);
        DPrint.log("verify otp success result : ${fail.message}");
        setLoading(false);
      },
      (success) {
        DPrint.log("verify otp success result : ${success.data.message}");
        Get.to(SetNewPasswordScreen(email: email, otp: otp));
        setLoading(false);
      },
    );
  }

  Future setNewPass(String email, String otp, String newPassword) async {
    setLoading(true);
    setError("");

    final request = SetNewPasswordRequestModel(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
    final result = await _authRepository.setNewPassword(request);

    result.fold(
      (fail) {
        setError(fail.message);
        DPrint.log("New Password set failed result : ${fail.message}");
        setLoading(false);
      },
      (success) {
        DPrint.log(
          "New Password set successfully result : ${success.data.message}",
        );
        Get.to(LoginScreen());
        setLoading(false);
      },
    );
  }

  Future refreshToken() async {
    setLoading(true);

    final refreshToken = await _authStorageService.getRefreshToken();
    DPrint.log("Got refresh token: $refreshToken");
    final request = RefreshTokenRequestModel(refreshToken: refreshToken);

    final result = await _authRepository.refreshToken(request);

    final navi = result.fold(
      (fail) {
        DPrint.log("Refresh token failed: ${fail.message}");
        setLoading(false);
        return _isSuccess = false;
      },
      (success) async {
        DPrint.log("Refresh token success: ${success.message}");
        await _authStorageService.storeAccessToken(success.data.accessToken);
        await _authStorageService.storeRefreshToken(success.data.refreshToken);
        // _authStorageService.clearAuthData();
        setLoading(false);
        return _isSuccess = true;
      },
    );
    return navi;
  }

  Future<void> logout() async {
    await _authStorageService.clearAuthData();
    Get.offAll(() => LoginScreen());
  }
}
