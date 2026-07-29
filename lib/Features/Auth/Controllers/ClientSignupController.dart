import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/API/auth_api_client.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Widgets/AppLoader.dart';
import 'package:vclub/Features/Auth/Widgets/Client/VerifyCode.dart';

class ClientSignUpController extends GetxController { 
 final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final birthdayController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  // validate sign up data 
  bool validateRegister() {
  List<String> errors = [];

  // =========================
  // 1️⃣ First Name
  // =========================
  if (firstNameController.text.trim().isEmpty) {
    errors.add("first_name_required".tr);
  }

  // =========================
  // 2️⃣ Last Name
  // =========================
  if (lastNameController.text.trim().isEmpty) {
    errors.add("last_name_required".tr);
  }

  // =========================
  // 3️⃣ Email
  // =========================
  if (emailController.text.trim().isEmpty) {
    errors.add("email_required".tr);
  } else if (!GetUtils.isEmail(emailController.text.trim())) {
    errors.add("invalid_email".tr);
  }

  // =========================
  // 4️⃣ Phone
  // =========================
  if (phoneController.text.trim().isEmpty) {
    errors.add("phone_required".tr);
  } else if (!GetUtils.isPhoneNumber(phoneController.text.trim())) {
    errors.add("invalid_phone".tr);
  }

  // =========================
  // 5️⃣ Password
  // =========================
  final password = passwordController.text.trim();

if (password.isEmpty) {
  errors.add("password_required".tr);
} else {
  final regex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._-])[A-Za-z\d@$!%*?&._-]{8,}$',
  );

  if (!regex.hasMatch(password)) {
    errors.add("weak_password".tr);
  }
}

  // =========================
  // 6️⃣ Confirm Password
  // =========================
  final confirmPassword = confirmPasswordController.text.trim();

  if (confirmPassword.isEmpty) {
    errors.add("confirm_password_required".tr);
  } else if (confirmPassword != password) {
    errors.add("passwords_not_match".tr);
  }

  // =========================
  // 7️⃣ Birthday (OPTIONAL)
  // =========================
  final birthday = birthdayController.text.trim();

  if (birthday.isNotEmpty) {
    try {
      DateTime.parse(birthday); // validate ISO format
    } catch (e) {
      errors.add("invalid_birthday".tr);
    }
  }

  // =========================
  // ❌ Show errors
  // =========================
  if (errors.isNotEmpty) {
    AppSnackBar.multipleErrors(errors);
    return false;
  }

  return true;
}
  // Loading state
  final isLoading = false.obs;

  // Obscure password toggles (optional but useful)
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  // Form key (recommended for validation)
  final formKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    birthdayController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

 Map<String, dynamic> get signUpPayload {
  final Map<String, dynamic> data = {
    "firstName": firstNameController.text.trim(),
    "lastName": lastNameController.text.trim(),
    "email": emailController.text.trim(),
    "phone": phoneController.text.trim(),
    "password": passwordController.text,
    "language": Get.locale?.languageCode ?? "en",
  };

  /// Add birthday only if not empty
 final isoBirthday = toIsoDate(birthdayController.text);

  if (isoBirthday != null) {
    data["birthday"] = isoBirthday;
  }

  return data;
}

Future<void> signup_api() async {
  try {
    AppLoader.show();

    final response = await AuthApiClient.register(
      payload: signUpPayload,
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      AppSnackBar.error("Unexpected server response");
      return;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      AppLoader.hide();
      debugPrint("✅ SIGNUP SUCCESS");
      AppNavigator.to(VerifyCode(email: emailController.text.trim(),));
      

    } else {
      AppLoader.hide();
      final message =
          data["message"]?.toString() ?? "Registration failed";

      AppSnackBar.error(message);
    }
  } on DioException catch (e) {
    AppLoader.hide();
    final data = e.response?.data;

    final message = (data is Map<String, dynamic>)
        ? data["message"]?.toString()
        : null;

    AppSnackBar.error(message ?? "Network error, please try again");

  } catch (e, st) {
    AppLoader.hide();
    debugPrint("❌ SIGNUP ERROR: $e");
    debugPrint("$st");

    AppSnackBar.error("Unexpected error occurred");

  } 
}
 


String? toIsoDate(String? date) {
  if (date == null || date.trim().isEmpty) return null;

  try {
    return DateTime.parse(date).toIso8601String();
  } catch (e) {
    return null;
  }
}


  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthdayController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }


}