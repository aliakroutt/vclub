// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart'; // adjust path
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardTokenModel.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/AppShimmer.dart'; // adjust path
import 'package:vclub/Features/Client/Dashboard/View/Widgets/QrScanCard.dart';
import 'package:vclub/Features/Client/QRScanner/View/QrScanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyCardsTab extends StatelessWidget {
  const MyCardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientDashboardController.to;
    final isDark = Get.find<ThemeService>().isDarkMode.value;

    return Obx(() {
      final isLoading = controller.cardsLoading.value;
      final hasError = controller.cardsError.value.isNotEmpty;
      final cards = controller.cards;

      // ---------- LOADING ----------
      if (isLoading && cards.isEmpty) {
        return ListView(
          padding: const EdgeInsets.only(bottom: 30),
          shrinkWrap: true,
          primary: false,
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ShimmerLoyaltyCard(isDark: isDark),
            ),
          ),
        );
      }

      // ---------- ERROR (no cached data) ----------
      if (hasError && cards.isEmpty) {
        return _CardsErrorState(
          isDark: isDark,
          onRetry: () => controller.fetchCards(),
        );
      }

      // ---------- EMPTY ----------
      if (cards.isEmpty) {
        return ListView(
          shrinkWrap: true,
          primary: false,
          children: [
            _CardsEmptyState(isDark: isDark),
            const SizedBox(height: 16),
            QRScanCard(ontap: () => Get.to(QrScannerScreen())),
          ],
        );
      }

      // ---------- LOADED ----------
      return ListView(
        padding: const EdgeInsets.only(bottom: 30),
        shrinkWrap: true,
        primary: false,
        children: [
          ...cards.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LoyaltyCardView(card: c, ontap:  () => showCardQrDialog(context, card: c),),
            ),
          ),

          // 🔥 SPECIAL QR CARD
          QRScanCard(
            ontap: () {
              Get.to(QrScannerScreen());
            },
          ),
        ],
      );
    });
  }
}

// =========================
// MODE → ICON / COLOR (kept consistent with the stats + history screens)
// =========================
class _ModeMeta {
  final IconData icon;
  final Color color;
  const _ModeMeta(this.icon, this.color);
}

_ModeMeta _metaForMode(String mode) {
  switch (mode) {
    case 'stamps':
      return const _ModeMeta(Iconsax.award, Color(0xFF29B6F6));
    case 'cashback':
      return const _ModeMeta(Iconsax.money_recive, Color(0xFF4CAF50));
    case 'points':
    default:
      return const _ModeMeta(Iconsax.star_1, Color(0xFFFFB300));
  }
}

double _safeProgress(num value, num target) {
  if (target <= 0) return 0.0;
  return (value / target).clamp(0.0, 1.0).toDouble();
}

String _percentText(double progress) => '${(progress * 100).toStringAsFixed(0)}%';

// =========================
// REAL CARD
// =========================
class LoyaltyCardView extends StatelessWidget {
  final VoidCallback ontap;
  final VoidCallback? onClaimReward;
  final ClientCardModel card;

  const LoyaltyCardView({
    super.key,
    required this.card,
    required this.ontap,
    this.onClaimReward,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final meta = _metaForMode(card.program.mode);
    final accent = meta.color;

    return InkWell(
      onTap: ontap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardColor,
              Color.alphaBlend(
                accent.withOpacity(0.05),
                Theme.of(context).cardColor,
              ),
            ],
          ),
          border: Border.all(width: 1, color: accent.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.18),
              blurRadius: 24,
              spreadRadius: -6,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // decorative circles — clipped by the parent Container
            Positioned(
              top: -40,
              right: -30,
              child: _circle(accent.withOpacity(0.10), 130),
            ),
            Positioned(
              bottom: -55,
              left: -35,
              child: _circle(accent.withOpacity(0.06), 140),
            ),

            // subtle top sheen for a glassy, premium feel
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(size.width * 0.045),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CardHeader(card: card, accent: accent, icon: meta.icon),
                  SizedBox(height: size.height * 0.02),
                  _CardBody(card: card, accent: accent),
                  SizedBox(height: size.height * 0.015),
                  _CardFooter(card: card, accent: accent),
                  if (card.cardCompleted) ...[
                    SizedBox(height: size.height * 0.016),
                     _ClaimRewardButton(accent: accent, card: card, onTap: onClaimReward),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(Color color, double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

/// Premium "Claim Reward" button shown when a loyalty card is completed.
/// Uses a bold gradient fill, soft glow shadow, and a shimmer-friendly
/// icon+text layout to feel distinct from the rest of the card's softer,
/// tinted surfaces.
class _ClaimRewardButton extends StatelessWidget {
  final Color accent;
  final ClientCardModel card;
  final VoidCallback? onTap;

  const _ClaimRewardButton({
    required this.accent,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap?.call();
          showLoyaltyRewardQrDialog(context, card: card, accent: accent);
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.014),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [accent, Color.lerp(accent, Colors.white, 0.18)!],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.40),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.gift_copy, size: size.width * 0.045, color: Colors.white),
              SizedBox(width: size.width * 0.02),
              AppText(
                'claim_reward_client'.tr,
                fontSize: size.width * 0.035,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Shows a premium, responsive dialog with a QR code encoding the card's id,
/// so the merchant can scan it to validate the loyalty reward.
void showLoyaltyRewardQrDialog(
  BuildContext context, {
  required ClientCardModel card,
  required Color accent,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Transform.scale(
        scale: 0.9 + (0.1 * curved.value),
        child: Opacity(
          opacity: anim.value,
          child: _LoyaltyRewardQrDialog(card: card, accent: accent),
        ),
      );
    },
  );
}
// qr dialog 
class _LoyaltyRewardQrDialog extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;

  const _LoyaltyRewardQrDialog({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;

    // Cap the dialog width on large/tablet screens, but stay responsive
    // (86% of screen width) on phones.
    final dialogWidth = size.width < 480 ? size.width * 0.86 : 380.0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- Header ----------
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, Color.lerp(accent, Colors.black, 0.18)!],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.width * 0.022),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                      ),
                      child: Icon(
                        Iconsax.medal_star_copy,
                        color: Colors.white,
                        size: size.width * 0.055,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: AppText(
                        'loyalty_reward_title_client'.tr,
                        fontSize: size.width * 0.042,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.014),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.16),
                        ),
                        child: Icon(
                          Iconsax.close_circle,
                          color: Colors.white,
                          size: size.width * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- QR code ----------
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.03,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.width * 0.035),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accent.withOpacity(0.25), width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.15),
                            blurRadius: 18,
                            spreadRadius: -4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: card.id,
                        version: QrVersions.auto,
                        size: dialogWidth * 0.56,
                        backgroundColor: Colors.white,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color.lerp(accent, Colors.black, 0.35)!,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.022),

                    // ---------- Bottom instruction text ----------
                    AppText(
                      'claim_reward_instructions_client'.tr,
                      fontSize: size.width * 0.033,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 // loyalty card dialog 
 

/// Shows a premium, responsive dialog with a live QR token for the given
/// card, a countdown until expiration, and a refresh action to regenerate
/// the token before it expires.
void showCardQrDialog(BuildContext context, {required ClientCardModel card}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Transform.scale(
        scale: 0.9 + (0.1 * curved.value),
        child: Opacity(
          opacity: anim.value,
          child: _CardQrDialog(card: card),
        ),
      );
    },
  );
}

class _CardQrDialog extends StatefulWidget {
  final ClientCardModel card;
  const _CardQrDialog({required this.card});

  @override
  State<_CardQrDialog> createState() => _CardQrDialogState();
}

class _CardQrDialogState extends State<_CardQrDialog> {
  final controller = Get.find<ClientDashboardController>();

  ClientCardQrModel? _qr;
  bool _loading = true;
  bool _refreshing = false;
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _loadQr();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQr({bool isRefresh = false}) async {
    setState(() {
      if (isRefresh) {
        _refreshing = true;
      } else {
        _loading = true;
      }
    });

    final result = await controller.fetchCardQr(widget.card.id);

    if (!mounted) return;

    setState(() {
      _loading = false;
      _refreshing = false;
      if (result != null) {
        _qr = result;
        _secondsLeft = result.expiresIn;
      }
    });

    if (result != null) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _formattedCountdown {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _expired => _qr != null && _secondsLeft <= 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final accent = _metaForMode(widget.card.program.mode).color;
    final dialogWidth = size.width < 480 ? size.width * 0.86 : 380.0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- Header ----------
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, Color.lerp(accent, Colors.black, 0.18)!],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.width * 0.022),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                      ),
                      child: Icon(
                        _metaForMode(widget.card.program.mode).icon,
                        color: Colors.white,
                        size: size.width * 0.055,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            widget.card.program.name,
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if ((widget.card.tier).isNotEmpty) ...[
                            SizedBox(height: size.height * 0.006),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.022,
                                vertical: size.height * 0.002,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: AppText(
                                widget.card.tier.toUpperCase(),
                                fontSize: size.width * 0.026,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.014),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.16),
                        ),
                        child: Icon(
                          Iconsax.close_circle,
                          color: Colors.white,
                          size: size.width * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- QR / loading / body ----------
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.03,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: dialogWidth * 0.8,
                      height: dialogWidth * 0.8,
                      child: _loading
                          ? Center(
                              child: LoadingAnimationWidget.fourRotatingDots(
                                color: accent,
                                size: 32,
                              ),
                            )
                          : (_qr == null)
                              ? Icon(Iconsax.warning_2,
                                  color: Colors.grey.shade400, size: size.width * 0.12)
                              : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(size.width * 0.035),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: accent.withOpacity(0.25), width: 1.4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withOpacity(0.15),
                                            blurRadius: 18,
                                            spreadRadius: -4,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: QrImageView(
                                        data: _qr!.qrToken,
                                        version: QrVersions.auto,
                                        size: dialogWidth * 0.65,
                                        backgroundColor: Colors.white,
                                        eyeStyle: QrEyeStyle(
                                          eyeShape: QrEyeShape.square,
                                          color: Color.lerp(accent, Colors.black, 0.35)!,
                                        ),
                                        dataModuleStyle: QrDataModuleStyle(
                                          dataModuleShape: QrDataModuleShape.square,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    // Dim + overlay once expired.
                                    if (_expired)
                                      Container(
                                        width: dialogWidth * 0.62,
                                        height: dialogWidth * 0.62,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.55),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: AppText(
                                            'qr_expired_client'.tr,
                                            fontSize: size.width * 0.033,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // ---------- Timer + refresh ----------
                    if (!_loading && _qr != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.timer_1,
                            size: size.width * 0.045,
                            color: _expired
                                ? Colors.redAccent
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          ),
                          SizedBox(width: size.width * 0.018),
                          AppText(
                            _expired ? 'qr_expired_client'.tr : _formattedCountdown,
                            fontSize: size.width * 0.037,
                            fontWeight: FontWeight.w700,
                            color: _expired
                                ? Colors.redAccent
                                : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                          ),
                          SizedBox(width: size.width * 0.03),
                          InkWell(
                            onTap: _refreshing ? null : () => _loadQr(isRefresh: true),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: EdgeInsets.all(size.width * 0.02),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent.withOpacity(0.12),
                              ),
                              child: _refreshing
                                  ? SizedBox(
                                      width: size.width * 0.042,
                                      height: size.width * 0.042,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: accent,
                                      ),
                                    )
                                  : Icon(Iconsax.refresh, size: size.width * 0.042, color: accent),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: size.height * 0.022),

                    // ---------- Bottom instruction text ----------
                    AppText(
                      'card_qr_instructions_client'.tr,
                      fontSize: size.width * 0.033,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =========================
// HEADER — company branding + program name + visits + reward-ready chip
// =========================
class _CardHeader extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  final IconData icon;

  const _CardHeader({
    required this.card,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CompanyIconBox(logo: card.company.logo, icon: icon, accent: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                card.company.name,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppText(
                card.program.name,
                fontSize: 12,
                color: Colors.grey.withOpacity(0.7),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _VisitsBadge(visits: card.visits, accent: accent),
            if (card.cardCompleted) ...[
              const SizedBox(height: 4),
              _RewardReadyChip(accent: accent),
            ],
          ],
        ),
      ],
    );
  }
}

class _CompanyIconBox extends StatelessWidget {
  final String logo;
  final IconData icon;
  final Color accent;

  const _CompanyIconBox({
    required this.logo,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.18), accent.withOpacity(0.08)],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Shows the company's real logo when available, falls back to the
      // program-mode icon (star / stamp / cashback) if it's missing or fails.
      child: logo.isEmpty
          ? Icon(icon, color: accent, size: 20)
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(icon, color: accent, size: 20),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Icon(icon, color: accent, size: 20);
                },
              ),
            ),
    );
  }
}

class _VisitsBadge extends StatelessWidget {
  final int visits;
  final Color accent;
  const _VisitsBadge({required this.visits, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.repeat, size: 12, color: accent),
          const SizedBox(width: 4),
          AppText(
            '$visits',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ],
      ),
    );
  }
}

class _RewardReadyChip extends StatelessWidget {
  final Color accent;
  const _RewardReadyChip({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.gift, size: 11, color: Colors.white),
          const SizedBox(width: 3),
          AppText(
            'reward_ready_client'.tr,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

// =========================
// BODY — one of three layouts depending on program.mode
// =========================
class _CardBody extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _CardBody({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    switch (card.program.mode) {
      case 'stamps':
        return _StampsBody(card: card, accent: accent);
      case 'cashback':
        return _CashbackBody(card: card, accent: accent);
      case 'points':
      default:
        return _PointsBody(card: card, accent: accent);
    }
  }
}

class _PointsBody extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _PointsBody({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final target = card.program.pointsPerReward;
    final progress = _safeProgress(card.points, target);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [accent, accent.withOpacity(0.7)],
              ).createShader(bounds),
              child: AppText(
                '${card.points} ',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white, // replaced by ShaderMask
              ),
            ),
            AppText(
              target > 0
                  ? '/ $target ${'points_badge_client'.tr}'
                  : 'points_badge_client'.tr,
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        SizedBox(height: size.height * 0.012),
        _ProgressBar(progress: progress, accent: accent),
      ],
    );
  }
}

class _StampsBody extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _StampsBody({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    final target = card.program.stampsPerReward;
    final earned = card.stamps;
    final progress = _safeProgress(earned, target);

    // A visual dot grid only reads well for a small target; beyond that,
    // fall back to the same progress bar as points.
    final useDots = target > 0 && target <= 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [accent, accent.withOpacity(0.7)],
              ).createShader(bounds),
              child: AppText(
                '$earned ',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            AppText(
              target > 0
                  ? '/ $target ${'stamps_badge_client'.tr}'
                  : 'stamps_badge_client'.tr,
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (useDots)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(target, (i) {
              final filled = i < earned;
              return Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? accent : accent.withOpacity(0.12),
                  border: filled
                      ? null
                      : Border.all(color: accent.withOpacity(0.4)),
                ),
                child: filled
                    ? const Icon(Iconsax.award, size: 11, color: Colors.white)
                    : null,
              );
            }),
          )
        else
          _ProgressBar(progress: progress, accent: accent),
      ],
    );
  }
}

class _CashbackBody extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _CashbackBody({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'cashback_balance_client'.tr,
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [accent, accent.withOpacity(0.7)],
          ).createShader(bounds),
          child: AppText(
            '${card.cashbackBalance}€',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Iconsax.percentage_circle, size: 14, color: accent),
            const SizedBox(width: 4),
            Flexible(
              child: AppText(
                '${'cashback_earn_rate_client'.tr} ${card.program.cashbackPercent}%',
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color accent;
  const _ProgressBar({required this.progress, required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 8,
        width: double.infinity,
        color: Colors.grey.withOpacity(0.3),
        child: FractionallySizedBox(
          // AlignmentDirectional.centerStart = left in LTR, right in RTL
          alignment: AlignmentDirectional.centerStart,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [accent.withOpacity(0.7), accent],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================
// FOOTER — tier badge + a mode-specific trailing hint
// =========================
class _CardFooter extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _CardFooter({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    final mode = card.program.mode;
    String? trailingText;

    if (mode == 'points') {
      final target = card.program.pointsPerReward;
      if (target > 0) {
        trailingText = _percentText(_safeProgress(card.points, target));
      }
    } else if (mode == 'stamps') {
      final target = card.program.stampsPerReward;
      if (target > 0) {
        trailingText = _percentText(_safeProgress(card.stamps, target));
      }
    } else if (mode == 'cashback' && card.program.cashbackMinPurchase > 0) {
      trailingText =
          '${'cashback_min_purchase_client'.tr} ${card.program.cashbackMinPurchase}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: accent.withOpacity(0.12),
          ),
          child: AppText(
            card.tier.toUpperCase(),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
        if (trailingText != null)
          AppText(
            trailingText,
            fontWeight: FontWeight.w800,
            color: accent,
            fontSize: 14,
          ),
      ],
    );
  }
}

// =========================
// SHIMMER PLACEHOLDER CARD
// =========================
class _ShimmerLoyaltyCard extends StatelessWidget {
  final bool isDark;
  const _ShimmerLoyaltyCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AppShimmer(
      isDark: isDark,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.045),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBlock(width: 40, height: 40, radius: 14, isDark: isDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBlock(
                        width: size.width * 0.3,
                        height: 12,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 6),
                      ShimmerBlock(
                        width: size.width * 0.4,
                        height: 10,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                ShimmerBlock(
                  width: 40,
                  height: 20,
                  radius: 20,
                  isDark: isDark,
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            ShimmerBlock(width: size.width * 0.3, height: 22, isDark: isDark),
            const SizedBox(height: 10),
            ShimmerBlock(
              width: double.infinity,
              height: 8,
              radius: 20,
              isDark: isDark,
            ),
            SizedBox(height: size.height * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBlock(width: 60, height: 20, radius: 12, isDark: isDark),
                ShimmerBlock(width: 40, height: 14, isDark: isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// ERROR STATE
// =========================
class _CardsErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _CardsErrorState({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.78),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        children: [
          const Icon(Iconsax.warning_2, color: Colors.redAccent, size: 28),
          const SizedBox(height: 8),
          AppText(
            'failed_load_cards'.tr,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: AppText(
              'retry'.tr,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// EMPTY STATE
// =========================
class _CardsEmptyState extends StatelessWidget {
  final bool isDark;
  const _CardsEmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.03),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.card,
            color: isDark ? Colors.white38 : Colors.black26,
            size: 30,
          ),
          const SizedBox(height: 8),
          AppText(
            'no_cards_client'.tr,
            fontSize: 13,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}