import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/Settings/Services/SettingsApiClient.dart';
import 'package:vclub/Features/Merchant/Settings/Utils/PasswordStrength.dart';

class ClientPasswordController extends GetxController {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool showCurrent = false.obs;
  final RxBool showNew = false.obs;
  final RxBool showConfirm = false.obs;
  final RxBool savingPassword = false.obs;

  final RxString newPasswordValue = "".obs;

  @override
  void onInit() {
    super.onInit();
    newPasswordController.addListener(() {
      newPasswordValue.value = newPasswordController.text;
    });
  }

  void toggleCurrent() => showCurrent.value = !showCurrent.value;
  void toggleNew() => showNew.value = !showNew.value;
  void toggleConfirm() => showConfirm.value = !showConfirm.value;

  Future<bool> updatePassword() async {
  final current = currentPasswordController.text;
  final newPass = newPasswordController.text;
  final confirm = confirmPasswordController.text;

  if (current.isEmpty) {
    AppSnackBar.error("current_password_required".tr);
    return false;
  }

  final validationError = PasswordStrength.validate(newPass);
  if (validationError != null) {
    AppSnackBar.error(validationError.tr);
    return false;
  }

  if (newPass != confirm) {
    AppSnackBar.error("passwords_do_not_match".tr);
    return false;
  }

  if (current == newPass) {
    AppSnackBar.error("new_password_same_as_current".tr);
    return false;
  }

  try {
    savingPassword.value = true;

    final result = await SettingsApiClient.changePassword(
      currentPassword: current,
      newPassword: newPass,
    );

    if (result.success) {
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      newPasswordValue.value = "";
      AppSnackBar.success("password_updated".tr);
      return true;
    } else {
      AppSnackBar.error(result.errorMessage ?? "change_password_failed_generic".tr);
      return false;
    }
  } finally {
    savingPassword.value = false;
  }
}

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}