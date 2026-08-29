import 'dart:async';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vclub/API/ApiRoutes.dart';

/// Wraps the Socket.IO connection to the VClub realtime gateway.
///
/// One instance lives for the whole app session (register with
/// `Get.put(SocketService(), permanent: true)` in main(), after login/token
/// is available — see connect()).
///
/// Controllers subscribe to the exposed streams for the events they care
/// about instead of talking to the socket directly.
class SocketService extends GetxService {
  static SocketService get to => Get.find();
  IO.Socket? _socket;

  final RxBool isConnected = false.obs;

  // ── Broadcast streams, one per backend event ───────────────────────────
  final _pointsAddedCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _rewardRedeemedCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  final _rewardValidatedCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  final _liveFeedCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _membershipJoinedCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  final _subscriptionRevokedCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  final _subscriptionRestoredCtrl =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Client app — staff scanned the client and awarded points/stamp/cashback.
  Stream<Map<String, dynamic>> get onPointsAdded => _pointsAddedCtrl.stream;

  /// Client app — client redeemed a reward.
  Stream<Map<String, dynamic>> get onRewardRedeemed =>
      _rewardRedeemedCtrl.stream;

  /// Client app — staff validated the client's reward coupon.
  Stream<Map<String, dynamic>> get onRewardValidated =>
      _rewardValidatedCtrl.stream;

  /// Merchant app — any scan in the commerce (live activity feed).
  Stream<Map<String, dynamic>> get onLiveFeed => _liveFeedCtrl.stream;

  /// Merchant app — a new client joined the commerce.
  Stream<Map<String, dynamic>> get onMembershipJoined =>
      _membershipJoinedCtrl.stream;

  /// Merchant app — subscription ended, route to renewal/paywall.
  Stream<Map<String, dynamic>> get onSubscriptionRevoked =>
      _subscriptionRevokedCtrl.stream;

  /// Merchant app — subscription reactivated.
  Stream<Map<String, dynamic>> get onSubscriptionRestored =>
      _subscriptionRestoredCtrl.stream;

  static final String _baseUrl = ApiRoutes.socketHost;

  /// Opens the socket connection using the given JWT access token.
  /// Safe to call again with a fresh token — see [updateToken] which is
  /// preferred for refresh flows, this handles first-connect + edge cases.
  void connect(String accessToken) {
    if (_socket != null) {
      updateToken(accessToken);
      return;
    }

    _socket = IO.io(
      _baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': accessToken})
          .setTimeout(20000) // 20s, was probably shorter by default
          .enableReconnection()
          .build(),
    );

    _registerListeners();
    _socket!.connect();
  }

  void _registerListeners() {
    final socket = _socket;
    if (socket == null) return;

    socket.onConnect((_) {
      isConnected.value = true;
      _log('connected');
    });

    socket.onDisconnect((_) {
      isConnected.value = false;
      _log('disconnected');
    });

    socket.onConnectError((err) => _log('connect error: $err'));
    socket.onError((err) => _log('error: $err'));

    // Client app
    socket.on('scan:points_added', (data) => _emit(_pointsAddedCtrl, data));
    socket.on(
      'scan:reward_redeemed',
      (data) => _emit(_rewardRedeemedCtrl, data),
    );
    socket.on(
      'scan:reward_validated',
      (data) => _emit(_rewardValidatedCtrl, data),
    );

    // Merchant / agent app
    socket.on('scan:live_feed', (data) {
      print('[SocketService] RAW scan:live_feed: $data');
      _emit(_liveFeedCtrl, data);
    });
    socket.on('membership:joined', (data) {
      print('[SocketService] RAW membership:joined: $data');
      _emit(_membershipJoinedCtrl, data);
    });
    socket.on('subscription:revoked', (data) {
      print('[SocketService] RAW subscription:revoked: $data');
      _emit(_subscriptionRevokedCtrl, data);
    });
    socket.on('subscription:restored', (data) {
      print('[SocketService] RAW subscription:restored: $data');
      _emit(_subscriptionRestoredCtrl, data);
    });
  }

  void _emit(StreamController<Map<String, dynamic>> ctrl, dynamic data) {
    if (data is Map) {
      ctrl.add(Map<String, dynamic>.from(data));
    } else {
      _log('unexpected payload shape: $data');
    }
  }

  /// Call this right after a successful /auth/refresh with the new token.
  /// Per the docs, the token is only checked at handshake time, so a live
  /// socket keeps running on an old token — but a fresh connection (e.g.
  /// after a drop) needs the new one, hence updating + forcing a reconnect.
  void updateToken(String newAccessToken) {
    final socket = _socket;
    if (socket == null) {
      connect(newAccessToken);
      return;
    }
    socket.auth = {'token': newAccessToken};
    socket.disconnect();
    socket.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[SocketService] $message');
  }

  @override
  void onClose() {
    disconnect();
    for (final c in [
      _pointsAddedCtrl,
      _rewardRedeemedCtrl,
      _rewardValidatedCtrl,
      _liveFeedCtrl,
      _membershipJoinedCtrl,
      _subscriptionRevokedCtrl,
      _subscriptionRestoredCtrl,
    ]) {
      c.close();
    }
    super.onClose();
  }
}
