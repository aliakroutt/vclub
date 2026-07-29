import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Features/Auth/Widgets/ForgetPasswordWidgets/SuccessChangePassword.dart';

class ForgotPasswordController extends GetxController {
  

  final RxInt currentStep = 0.obs;

  static  int totalSteps = 3;

  

  final emailController = TextEditingController();

  
final List<TextEditingController> otpControllers =
    List.generate(6, (_) => TextEditingController());

final List<FocusNode> otpFocus =
    List.generate(6, (_) => FocusNode());

String get otpCode =>
    otpControllers.map((e) => e.text).join();



void resendCode() {
  // API call
}

final newPasswordController = TextEditingController();
final confirmPasswordController = TextEditingController();

final isNewPasswordHidden = true.obs;
final isConfirmPasswordHidden = true.obs;

void toggleNewPassword() {
  isNewPasswordHidden.value = !isNewPasswordHidden.value;
}

void toggleConfirmPassword() {
  isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
}

void resetPassword() {
  final newPass = newPasswordController.text.trim();
  final confirmPass = confirmPasswordController.text.trim();

  if (newPass.length < 8) return;
  if (newPass != confirmPass) return;
  AppNavigator.to(SuccessChanegePassword());
    resetAllData();
  
}
  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  void resetAllData() {
  // Step reset
  currentStep.value = 0;
  // Email
  emailController.clear();

  // OTP
  for (final c in otpControllers) {
    c.clear();
  }

  // Focus nodes (optional safety reset)
  for (final f in otpFocus) {
    f.unfocus();
  }

  // Passwords
  newPasswordController.clear();
  confirmPasswordController.clear();

  // Hide passwords again
  isNewPasswordHidden.value = true;
  isConfirmPasswordHidden.value = true;
}
}
