// lib/Core/Sockets/MerchantRealtimeController.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:vclub/API/SocketService.dart';
import 'package:vclub/API/Socket/Models/ScanLiveFeedEvent.dart';
import 'package:vclub/API/Socket/Models/MembershipJoinedEvent.dart';
import 'package:vclub/API/Socket/Models/SubscriptionRevokedEvent.dart';
import 'package:vclub/API/Socket/Models/SubscriptionRestoredEvent.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Core/Storage/Controllers/AgentController.dart';
import 'package:vclub/Core/Widgets/PremiumSnackbar.dart';
import 'package:vclub/Features/Auth/Services/MerchantService.dart';
import 'package:vclub/Features/Auth/Services/AgentService.dart';
import 'package:vclub/Core/Storage/Eneums.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Features/Merchant/Main/Controllers/MerchantMainController.dart';

/// Wires the merchant/staff realtime notifications: live scan feed,
/// new-member alerts, and subscription state changes. Register once
/// (permanent) after a merchant/agent logs in or resumes a session.
class MerchantRealtimeController extends GetxController {
  static MerchantRealtimeController get to => Get.find();

  StreamSubscription<Map<String, dynamic>>? _liveFeedSub;
  StreamSubscription<Map<String, dynamic>>? _membershipJoinedSub;
  StreamSubscription<Map<String, dynamic>>? _revokedSub;
  StreamSubscription<Map<String, dynamic>>? _restoredSub;

  bool _listening = false;

  /// Starts listening to the merchant realtime socket events. Safe to call
  /// multiple times — subsequent calls are no-ops if already listening.
  /// Call this explicitly after the socket is confirmed connected, instead
  /// of relying on onInit() timing.
  void startListening() {
    if (_listening) {
      print('[MerchantRealtimeController] startListening called but already listening — skipping');
      return;
    }

    print('[MerchantRealtimeController] startListening — attaching listeners');
    _listening = true;

    _liveFeedSub = SocketService.to.onLiveFeed.listen(_onLiveFeed);
    _membershipJoinedSub = SocketService.to.onMembershipJoined.listen(_onMembershipJoined);
    _revokedSub = SocketService.to.onSubscriptionRevoked.listen(_onSubscriptionRevoked);
    _restoredSub = SocketService.to.onSubscriptionRestored.listen(_onSubscriptionRestored);
  }

  void stopListening() {
    _liveFeedSub?.cancel();
    _membershipJoinedSub?.cancel();
    _revokedSub?.cancel();
    _restoredSub?.cancel();
    _listening = false;
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }

  void _onLiveFeed(Map<String, dynamic> data) {
    print('[MerchantRealtimeController] onLiveFeed fired: $data');
    final event = ScanLiveFeedEvent.fromJson(data);

    PremiumSnackbar.show(
      title: 'live_feed_title_merchant'.trParams({'name': event.clientName}),
      message: _actionMessage(event.action, event.awarded),
      type: SnackType.info,
    );
  }

  void _onMembershipJoined(Map<String, dynamic> data) {
    print('[MerchantRealtimeController] onMembershipJoined fired: $data');
    final event = MembershipJoinedEvent.fromJson(data);

    PremiumSnackbar.show(
      title: 'membership_joined_title_merchant'.tr,
      message: 'membership_joined_message_merchant'.trParams({
        'name': event.clientName,
        'program': event.programName ?? '',
      }),
      type: SnackType.success,
    );
  }

  Future<void> _onSubscriptionRevoked(Map<String, dynamic> data) async {
    print('[MerchantRealtimeController] onSubscriptionRevoked fired: $data');
    final event = SubscriptionRevokedEvent.fromJson(data);
    
    PremiumSnackbar.show(
      title: 'subscription_revoked_title_merchant'.tr,
      message: _revokedReasonMessage(event.reason),
      type: SnackType.error,
      duration: const Duration(seconds: 7),
    );

    await _refreshProfile();
    final controller = Get.find<MerchantMainController>();
    controller.selectIndex(11);
  }

  Future<void> _onSubscriptionRestored(Map<String, dynamic> data) async {
    print('[MerchantRealtimeController] onSubscriptionRestored fired: $data');
    final event = SubscriptionRestoredEvent.fromJson(data);
    final controller = Get.find<MerchantMainController>();
    PremiumSnackbar.show(
      title: 'subscription_restored_title_merchant'.tr,
      message: 'subscription_restored_message_merchant'.trParams({'plan': event.plan}),
      type: SnackType.success,
      duration: const Duration(seconds: 6),
    );

    await _refreshProfile();
    controller.selectIndex(11);
  }

  Future<void> _refreshProfile() async {
    final role = TokenStorage.userRole;

    if (role == UserRole.agent) {
      final profile = await AgentService.profile();
      if (profile == null) return;
      await AgentController.to.saveAgent(profile);
    } else {
      final profile = await MerchantService.profile();
      if (profile == null) return;
      await MerchantController.to.saveMerchant(profile);
    }
  }

  String _actionMessage(String action, num awarded) {
    switch (action) {
      case 'add_stamp':
        return 'live_feed_stamp_merchant'.trParams({'amount': '$awarded'});
      case 'cashback':
        return 'live_feed_cashback_merchant'.trParams({'amount': '$awarded'});
      case 'reward_redeemed':
        return 'live_feed_reward_redeemed_merchant'.tr;
      case 'reward_validated':
        return 'live_feed_reward_validated_merchant'.tr;
      case 'add_points':
      default:
        return 'live_feed_points_merchant'.trParams({'amount': '$awarded'});
    }
  }

  String _revokedReasonMessage(SubscriptionRevokedReason reason) {
    switch (reason) {
      case SubscriptionRevokedReason.canceled:
        return 'subscription_reason_canceled_merchant'.tr;
      case SubscriptionRevokedReason.expired:
        return 'subscription_reason_expired_merchant'.tr;
      case SubscriptionRevokedReason.paymentFailed:
        return 'subscription_reason_payment_failed_merchant'.tr;
      case SubscriptionRevokedReason.suspended:
        return 'subscription_reason_suspended_merchant'.tr;
      case SubscriptionRevokedReason.unknown:
        return 'subscription_reason_unknown_merchant'.tr;
    }
  }
}