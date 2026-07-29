import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AppSnackBar {
  // =========================
  // SUCCESS
  // =========================
  static void success(String message) {
    Get.snackbar(
      "success".tr,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
      borderRadius: 14,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 2),
      boxShadows: [
        BoxShadow(
          color: Colors.green.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  // =========================
  // ERROR (single)
  // =========================
  static void error(String message) {
    Get.snackbar(
      "error".tr,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade800,
      borderRadius: 14,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.error, color: Colors.red),
      duration: const Duration(seconds: 2),
    );
  }

  // =========================
  // WARNING
  // =========================
  static void warning(String message) {
    Get.snackbar(
      "warning".tr,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.shade50,
      colorText: Colors.orange.shade800,
      borderRadius: 14,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.warning_amber, color: Colors.orange),
      duration: const Duration(seconds: 2),
    );
  }

  // =========================
  // INFO
  // =========================
  static void info(String message) {
    Get.snackbar(
      "info".tr,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
      borderRadius: 14,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.info, color: Colors.blue),
      duration: const Duration(seconds: 2),
    );
  }

  // =========================
  // MULTIPLE ERRORS (your style)
  // =========================
  static void multipleErrors(List<String> errors) {
    Get.snackbar(
      "error".tr,
      "",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade50,
      borderRadius: 14,
      margin: const EdgeInsets.all(12),
      titleText: Text(
        "error".tr,
        style: TextStyle(
          color: Colors.red.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        errors.join("\n"),
        style: TextStyle(
          color: Colors.red.shade700,
          height: 1.4,
        ),
      ),
      icon: const Icon(Icons.error, color: Colors.red),
      duration: const Duration(seconds: 3),
    );
  }
}