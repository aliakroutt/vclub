import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';
import 'package:vclub/Features/Merchant/QRScanner/Models/ScanModels.dart';

class RedeemSuccessDialog {
  static Future<void> show({required RedeemResultModel result}) {
    return Get.dialog(
      _RedeemSuccessView(result: result),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
    );
  }
}

class _RedeemSuccessView extends StatefulWidget {
  final RedeemResultModel result;
  const _RedeemSuccessView({required this.result});

  @override
  State<_RedeemSuccessView> createState() => _RedeemSuccessViewState();
}

class _RedeemSuccessViewState extends State<_RedeemSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _checkScale;
  final controller = MerchantDashboardController.to;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = AppColors.primary;

    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => Opacity(
          opacity: _fade.value,
          child: Transform.scale(scale: _scale.value, child: child),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.07,
                    vertical: size.height * 0.04,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.9),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// ── ICON ────────────────────────
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: size.width * 0.24,
                            height: size.width * 0.24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  accent.withValues(alpha: 0.18),
                                  accent.withValues(alpha: 0.04),
                                ],
                              ),
                            ),
                          ),
                          ScaleTransition(
                            scale: _checkScale,
                            child: Container(
                              width: size.width * 0.17,
                              height: size.width * 0.17,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [accent, accent.withValues(alpha: 0.75)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Iconsax.ticket_discount,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.026),

                      AppText(
                        "reward_redeemed".tr,
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.008),
                      AppText(
                        "redeem_success_desc".trParams({
                          "reward": widget.result.reward.name,
                        }),
                        fontSize: size.width * 0.033,
                        textAlign: TextAlign.center,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.6),
                      ),

                      /// ── REWARD NAME BANNER ────────
                      SizedBox(height: size.height * 0.022),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(size.width * 0.035),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: accent.withValues(alpha: 0.1),
                          border: Border.all(color: accent.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Iconsax.gift, color: accent),
                            SizedBox(width: size.width * 0.025),
                            Expanded(
                              child: AppText(
                                widget.result.reward.name,
                                fontWeight: FontWeight.w700,
                                fontSize: size.width * 0.036,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),

                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.062,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            Get.back();
                            controller.fetchDashboardData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: AppText(
                            "done".tr,
                            fontSize: size.width * 0.038,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}