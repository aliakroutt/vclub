import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';

class ApiInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token =  TokenStorage.getAccessToken();

      options.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Accept-Language': Get.locale?.languageCode ?? 'en',
      });

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      handler.next(options);
    } catch (e) {
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    final isLoginRoute = requestOptions.path.contains(ApiRoutes.Login);
    final isRefreshRoute = requestOptions.path.contains(ApiRoutes.refreshToken);

    if (err.response?.statusCode == 401 && !isLoginRoute && !isRefreshRoute) {
      try {
        final response = await _handleTokenRefresh(err);
        if (response != null) {
          handler.resolve(response);
          return;
        }
      } catch (_) {
        // fall through to handler.next below
      }
    }

    handler.next(err);
  }

  Future<Response<dynamic>?> _handleTokenRefresh(DioException err) async {
    final requestOptions = err.requestOptions;

    final completer = _PendingRequest(requestOptions);
    _pendingRequests.add(completer);

    if (_isRefreshing) {
      return completer.completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken =  TokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await _forceLogout();
        _rejectPending(Exception("No refresh token"));
        return null;
      }

      // IMPORTANT: use a bare Dio here, not ApiClient.instance,
      // so this call never gets caught by this same interceptor again.
      final refreshDio = Dio(BaseOptions(baseUrl: ApiRoutes.baseUrl));
      final response = await refreshDio.post(
        ApiRoutes.refreshToken,
        data: {"refreshToken": refreshToken},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception("Refresh token response malformed");
      }

      final newAccessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;

      if (newAccessToken == null || newRefreshToken == null) {
        throw Exception("Refresh token response missing tokens");
      }

      await TokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      for (final pending in _pendingRequests) {
        try {
          final res = await _retryRequest(pending.requestOptions);
          pending.completer.complete(res);
        } catch (e) {
          pending.completer.completeError(e);
        }
      }

      _pendingRequests.clear();
      _isRefreshing = false;

      return await _retryRequest(requestOptions);
    } catch (e) {
      _rejectPending(e);
      _pendingRequests.clear();
      _isRefreshing = false;
      await _forceLogout();
      return null;
    }
  }

  void _rejectPending(Object error) {
    for (final pending in _pendingRequests) {
      if (!pending.completer.isCompleted) {
        pending.completer.completeError(error);
      }
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = TokenStorage.getAccessToken();

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      responseType: ResponseType.json,
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );

    return ApiClient.instance.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _forceLogout() async {
    
    
  }
}

class _PendingRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer = Completer<Response>();
  _PendingRequest(this.requestOptions);
}