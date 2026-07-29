import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  NetworkInfo._();

  static final Connectivity _connectivity = Connectivity();

  static Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();

    return result != ConnectivityResult.none;
  }

  static Stream<List<ConnectivityResult>> get stream =>
      _connectivity.onConnectivityChanged;
}