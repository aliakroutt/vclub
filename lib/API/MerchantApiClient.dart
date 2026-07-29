import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';

class MerchantApiClient {
  MerchantApiClient._();

  static final Dio _dio = ApiClient.instance;

  //==========================================================
  // MERCHANT SIGN UP
  //==========================================================

  static Future<Response> signUp({
    required Map<String, dynamic> payload,
  }) {
    return _dio.post(
      ApiRoutes.register_merchant,
      data: payload,
    );
  }

  //==========================================================
  // UPLOAD LOGO
  //==========================================================

  static Future<Response> uploadLogo({
    required File file,
  }) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    return _dio.post(
      ApiRoutes.upload_logo,
      data: formData,
    );
  }
  static Future<Response> confirmPayment({required String sessionId}) {
  return _dio.post(
    ApiRoutes.confirm_payment,
    data: {"sessionId": sessionId},
  );
}
}