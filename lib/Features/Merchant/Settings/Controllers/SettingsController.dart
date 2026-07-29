import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class SettingsController extends GetxController {
  final googleReviewController = TextEditingController(
    text: "https://g.page/r/your-link",
  );

  final Rx<File?> logoFile = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  Future<void> pickLogo() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      logoFile.value = File(image.path);
    }
  }

  void removeLogo() {
    logoFile.value = null;
  }
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool showCurrent = false.obs;
  final RxBool showNew = false.obs;
  final RxBool showConfirm = false.obs;

  void toggleCurrent() => showCurrent.value = !showCurrent.value;
  void toggleNew() => showNew.value = !showNew.value;
  void toggleConfirm() => showConfirm.value = !showConfirm.value;

  void updatePassword() {
    final current = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    if (newPass != confirm) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    // TODO: call API here
    Get.snackbar("Success", "Password updated successfully");
  }
  @override
  void dispose() {
    googleReviewController.dispose();
    super.dispose();
  }
}