import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/API/Socket/Models/ScanPointsAddedEvent.dart';
import 'package:vclub/API/Socket/Models/ScanRewardValidatedEvent.dart';
import 'package:vclub/API/SocketService.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Cards/Controllers/GoogleWalletController.dart';

import 'package:vclub/Features/Client/Cards/View/Widgets/AnimatedCard.dart';
import 'package:vclub/Features/Client/Cards/View/Widgets/CardsDetailsExtra.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';

class CardDetails extends StatefulWidget {
  final ClientCardModel card;
  const CardDetails({super.key, required this.card});

  @override
  State<CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  final GlobalKey previewCard = GlobalKey();

  // Local mutable copy — the page starts with widget.card and swaps this
  // in whenever a matching realtime scan event arrives, so the animated
  // card + stats panel update instantly without needing to leave the page.
  late ClientCardModel _card;
  StreamSubscription<Map<String, dynamic>>? _pointsSub;
  StreamSubscription<Map<String, dynamic>>? _rewardSub;

  @override
  void initState() {
    super.initState();
    _card = widget.card;

    if (!Get.isRegistered<GoogleWalletController>()) {
      Get.put(GoogleWalletController());
    }

    _pointsSub = SocketService.to.onPointsAdded.listen(_onPointsAdded);
    _rewardSub = SocketService.to.onRewardValidated.listen(_onRewardValidated);
  }

  @override
  void dispose() {
    _pointsSub?.cancel();
    _rewardSub?.cancel();
    super.dispose();
  }

  void _onPointsAdded(Map<String, dynamic> data) {
    if (!mounted) return;

    final event = ScanPointsAddedEvent.fromJson(data);
    if (event.companyId != _card.company.id) return;

    setState(() {
      _card = _card.copyWith(
        points: event.points,
        stamps: event.stamps,
        cashbackBalance: event.cashbackBalance,
        cardCompleted: event.cardCompleted,
      );
    });

    // Keep the dashboard's cards list (used elsewhere in the app) in sync
    // too, so navigating back shows the same up-to-date data.
    Get.find<ClientDashboardController>().fetchDashboardData();
  }

  void _onRewardValidated(Map<String, dynamic> data) async {
    if (!mounted) return;

    final event = ScanRewardValidatedEvent.fromJson(data);
    if (event.companyId != _card.company.id) return;

    // The payload doesn't carry updated points/stamps, so we can't
    // copyWith blindly like _onPointsAdded — optimistically clear the
    // reward-ready state, then refresh from the API and swap in the
    // authoritative updated card once it comes back.
    setState(() {
      _card = _card.copyWith(cardCompleted: false);
    });

    final dashboard = Get.find<ClientDashboardController>();
    await dashboard.fetchDashboardData();

    if (!mounted) return;

    final refreshed = dashboard.cards.firstWhereOrNull((c) => c.id == _card.id);
    if (refreshed != null) {
      setState(() => _card = refreshed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';
    final isDark = Get.find<ThemeService>().isDarkMode.value;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _circleButton(
                context,
                icon: isRTL
                    ? Iconsax.arrow_right_3_copy
                    : Iconsax.arrow_left_2_copy,
                onTap: () => Get.back(),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              // key: ValueKey ties the widget's identity to the current
              // stat values, so TweenAnimationBuilders inside
              // LoyaltyCardViewAnimated (points/stamps/cashback count-up)
              // re-trigger their entrance animation on each realtime update
              // instead of silently jumping to the new value.
              child: LoyaltyCardViewAnimated(
                key: ValueKey(
                  '${_card.points}-${_card.stamps}-${_card.cashbackBalance}-${_card.cardCompleted}',
                ),
                card: _card,
              ),
            ),
            Spacer(),
            LoyaltyCardDetailsPanel(
              card: _card,
              onAppleWallet: () {},
              onGoogleWallet: () =>
                  Get.find<GoogleWalletController>().addToGoogleWallet(_card.id),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _circleButton(
  BuildContext context, {
  required IconData icon,
  required VoidCallback onTap,
}) {
  final isDark = Get.isDarkMode;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(.3)
                : Colors.black.withOpacity(.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 18),
    ),
  );
}