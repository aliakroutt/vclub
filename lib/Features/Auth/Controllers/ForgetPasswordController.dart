import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/API/auth_api_client.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Auth/Widgets/ForgetPasswordWidgets/SuccessChangePassword.dart';

class ForgotPasswordController extends GetxController {
  final RxInt currentStep = 0.obs;

  static int totalSteps = 3;

  final emailController = TextEditingController();

  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocus = List.generate(6, (_) => FocusNode());

  String get otpCode => otpControllers.map((e) => e.text).join();

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isNewPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  // ── LOADING STATES ──
  final isSendingCode = false.obs;
  final isVerifyingCode = false.obs;
  final isResettingPassword = false.obs;
  final isResending = false.obs;

  // ── HOLDS THE resetToken RETURNED BY /auth/verify-reset-code ──
  String? _resetToken;

  void toggleNewPassword() {
    isNewPasswordHidden.value = !isNewPasswordHidden.value;
  }

  void toggleConfirmPassword() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // =========================
  // VALIDATION
  // =========================
  bool _validateEmail() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      AppSnackBar.error("email_required".tr);
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      AppSnackBar.error("invalid_email".tr);
      return false;
    }
    return true;
  }

  bool _validateOtp() {
    if (otpCode.length < 6) {
      AppSnackBar.error("otp_incomplete".tr);
      return false;
    }
    return true;
  }

  bool _validateNewPassword() {
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (newPass.isEmpty) {
      AppSnackBar.error("password_required".tr);
      return false;
    }
    if (newPass.length < 8) {
      AppSnackBar.error("password_too_short".tr);
      return false;
    }
    if (confirmPass.isEmpty) {
      AppSnackBar.error("confirm_password_required".tr);
      return false;
    }
    if (newPass != confirmPass) {
      AppSnackBar.error("passwords_do_not_match".tr);
      return false;
    }
    return true;
  }

  // =========================
  // STEP 1 — SEND CODE
  // =========================
  /// Returns true on success so the calling screen knows whether to
  /// advance to the next step.
  Future<bool> sendCode() async {
    if (!_validateEmail()) return false;

    try {
      isSendingCode.value = true;

      final response = await AuthApiClient.sendResetCode(
        email: emailController.text.trim(),
      );

      if (response.statusCode == 200) {
        AppSnackBar.success("reset_code_sent".tr);
        return true;
      }

      final data = response.data;
      final message = (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
      AppSnackBar.error(message ?? "reset_code_send_failed".tr);
      return false;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
      AppSnackBar.error(message ?? "network_error_try_again".tr);
      return false;
    } catch (e) {
      AppSnackBar.error("unexpected_error".tr);
      return false;
    } finally {
      isSendingCode.value = false;
    }
  }

  // =========================
  // RESEND CODE
  // =========================
  Future<void> resendCode() async {
    if (isResending.value) return;

    try {
      isResending.value = true;

      final response = await AuthApiClient.sendResetCode(
        email: emailController.text.trim(),
      );

      if (response.statusCode == 200) {
        AppSnackBar.success("reset_code_resent".tr);
      } else {
        final data = response.data;
        final message = (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
        AppSnackBar.error(message ?? "reset_code_send_failed".tr);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
      AppSnackBar.error(message ?? "network_error_try_again".tr);
    } catch (e) {
      AppSnackBar.error("unexpected_error".tr);
    } finally {
      isResending.value = false;
    }
  }

  // =========================
  // STEP 2 — VERIFY OTP
  // =========================
  Future<bool> verifyOtp() async {
    if (!_validateOtp()) return false;

    try {
      isVerifyingCode.value = true;

      final response = await AuthApiClient.verifyResetCode(
        email: emailController.text.trim(),
        code: otpCode,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = (data is Map<String, dynamic>) ? data["resetToken"]?.toString() : null;

        if (token == null || token.isEmpty) {
          AppSnackBar.error("otp_verify_failed".tr);
          return false;
        }

        _resetToken = token;
        return true;
      }

      final data = response.data;
      final message = (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
      AppSnackBar.error(message ?? "invalid_otp_code".tr);
      return false;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
      AppSnackBar.error(message ?? "network_error_try_again".tr);
      return false;
    } catch (e) {
      AppSnackBar.error("unexpected_error".tr);
      return false;
    } finally {
      isVerifyingCode.value = false;
    }
  }

  // =========================
  // STEP 3 — RESET PASSWORD
  // =========================
  Future<void> resetPassword() async {
    if (!_validateNewPassword()) return;

    if (_resetToken == null || _resetToken!.isEmpty) {
      AppSnackBar.error("reset_session_expired".tr);
      return;
    }

    try {
      isResettingPassword.value = true;

      final response = await AuthApiClient.resetPasswordWithToken(
        resetToken: _resetToken!,
        newPassword: newPasswordController.text.trim(),
      );

      if (response.statusCode == 200) {
        AppNavigator.to(SuccessChanegePassword());
        resetAllData();
      } else {
        final data = response.data;
        final message = (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
        AppSnackBar.error(message ?? "password_reset_failed".tr);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
      AppSnackBar.error(message ?? "network_error_try_again".tr);
    } catch (e) {
      AppSnackBar.error("unexpected_error".tr);
    } finally {
      isResettingPassword.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocus) {
      f.dispose();
    }
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void resetAllData() {
    currentStep.value = 0;
    emailController.clear();

    for (final c in otpControllers) {
      c.clear();
    }
    for (final f in otpFocus) {
      f.unfocus();
    }

    newPasswordController.clear();
    confirmPasswordController.clear();

    isNewPasswordHidden.value = true;
    isConfirmPasswordHidden.value = true;

    isSendingCode.value = false;
    isVerifyingCode.value = false;
    isResettingPassword.value = false;
    isResending.value = false;

    _resetToken = null;
  }
}