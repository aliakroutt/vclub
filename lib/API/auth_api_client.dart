import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';



class AuthApiClient {
  AuthApiClient._();

  static final Dio _dio = ApiClient.instance;

  //==========================================================
  // LOGIN
  //==========================================================

  static Future<Response> login({
    required String email,
    required String password,
  }) {
    return _dio.post(
      ApiRoutes.Login,
      data: {
        "email": email,
        "password": password,
      },
    );
  }

  //==========================================================
  // REGISTER
  //==========================================================

   static Future<Response> register({
  required Map<String, dynamic> payload,
}) {
  return ApiClient.instance.post(
    ApiRoutes.client_signup,
    data: payload,
  );
}

  //==========================================================
  // FORGOT PASSWORD
  //==========================================================

  static Future<Response> forgotPassword({
    required String email,
  }) {
    return _dio.post(
      ApiRoutes.Login,
      data: {
        "email": email,
      },
    );
  }

  //==========================================================
  // VERIFY OTP
  //==========================================================

  static Future<Response> verifyOtp({
  required String email,
  required String code,
}) {
  return _dio.post(
    ApiRoutes.verify_otp,
    data: {
      "email": email.trim(),
      "code": code.trim(),
    },
  );
}


// resend otp 
static Future<Response> resendOtp({
  required String email,
}) {
  return _dio.post(
    ApiRoutes.resend_otp,
    data: {
      "email": email.trim(),
    },
  );
}
  //==========================================================
  // RESET PASSWORD
  //==========================================================

  static Future<Response> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return _dio.post(
      ApiRoutes.Login,
      data: {
        "email": email,
        "otp": otp,
        "password": newPassword,
      },
    );
  }

  //==========================================================
  // REFRESH TOKEN (IMPORTANT)
  //==========================================================

  static Future<Response> refreshToken({
    required String refreshToken,
  }) {
    return _dio.post(
      ApiRoutes.Login,
      data: {
        "refresh_token": refreshToken,
      },
    );
  }

  //==========================================================
  // LOGOUT
  //==========================================================

  static Future<Response> logout() {
    return _dio.post(
      ApiRoutes.Login,
    );
  }
}