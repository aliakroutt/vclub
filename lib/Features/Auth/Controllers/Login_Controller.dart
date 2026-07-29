import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/API/auth_api_client.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Core/Storage/Eneums.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Core/Widgets/AppLoader.dart';
import 'package:vclub/Features/Auth/Services/ClientService.dart';
import 'package:vclub/Features/Auth/Services/MerchantService.dart';
import 'package:vclub/Features/Client/Main/Views/MainScreen.dart';
import 'package:vclub/Features/Merchant/Main/View/MerchantMain.dart';

class LoginController extends GetxController {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // States
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  void togglePassword() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // =========================
  // VALIDATION
  // =========================
  bool validateLogin() {
    List<String> errors = [];

    // 1️⃣ Email
    if (emailController.text.trim().isEmpty) {
      errors.add("email_required".tr);
    } else if (!GetUtils.isEmail(emailController.text.trim())) {
      errors.add("invalid_email".tr);
    }

    // 2️⃣ Password
    if (passwordController.text.trim().isEmpty) {
      errors.add("password_required".tr);
    }

    // ❌ Errors
    if (errors.isNotEmpty) {
      AppSnackBar.multipleErrors(errors);
      return false;
    }

    return true;
  }

  // login api
  Future<void> login_api({
    required String email,
    required String password,
  }) async {
    try {
      AppLoader.show();

      final response = await AuthApiClient.login(
        email: email,
        password: password,
      );
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        AppLoader.hide();
        AppSnackBar.error("Unexpected server response");
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final accessToken = data["accessToken"] as String?;
        final refreshToken = data["refreshToken"] as String?;

        if (accessToken == null || refreshToken == null) {
          AppLoader.hide();
          AppSnackBar.error("Login response missing tokens");
          return;
        }

        debugPrint("✅ LOGIN SUCCESS");
        await TokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // Your login response only ever contains "client" today, no "user"/"role" key.
        final clientJson = data["client"] as Map<String, dynamic>?;
        final userJson = data["user"] as Map<String, dynamic>?;

        final role = clientJson != null
            ? UserRole.client
            : UserRoleExtension.fromString(
                userJson?["role"]?.toString() ?? "CLIENT",
              );

        await TokenStorage.saveUserRole(role);

        if (role == UserRole.client) {
          final clientId = clientJson?["id"]?.toString();
          if (clientId != null) await TokenStorage.saveUserId(clientId);

          final profile = await ClientService.profile();
          AppLoader.hide();

          if (profile == null) {
            AppSnackBar.error("Failed to load profile");
            return;
          }
          await ClientController.to.saveClient(profile);
        } else {
          final userId = userJson?["id"]?.toString();
          final companyId = userJson?["companyId"]?.toString();
          if (userId != null) await TokenStorage.saveUserId(userId);
          await TokenStorage.saveCompanyId(companyId);

          final profile = await MerchantService.profile();
          AppLoader.hide();

          if (profile == null) {
            AppSnackBar.error("Failed to load profile");
            return;
          }
          await MerchantController.to.saveMerchant(profile);
        }

        switch (TokenStorage.userRole) {
          case UserRole.admin:
          case UserRole.agent:
            AppNavigator.to(MainScreenMerchant());
            break;
          case UserRole.client:
            AppNavigator.to(MainScreen());
            debugPrint("Access = ${TokenStorage.getAccessToken()}");
            debugPrint("Refresh = ${TokenStorage.getAccessToken()}");
            break;
          default:
            break;
        }

        // AppSnackBar.success("Login successful");
      } else {
        AppLoader.hide();
        final message = data["message"]?.toString() ?? "Login failed";
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
      debugPrint("❌ LOGIN ERROR: $e");
      debugPrint("$st");
      AppSnackBar.error("Unexpected error occurred");
    }
  }

  // =========================
  // LOGIN ACTION
  // =========================
  Future<void> login() async {
    if (!validateLogin()) return;
    login_api(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
