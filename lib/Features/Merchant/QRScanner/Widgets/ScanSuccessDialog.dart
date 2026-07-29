import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';
import 'package:vclub/Features/Merchant/QRScanner/Models/ScanModels.dart';


class ScanSuccessDialog {
  static Future<void> show({required ScanResultModel result}) {
    return Get.dialog(
      _ScanSuccessView(result: result),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      
    );
  }
}

class _ScanSuccessView extends StatefulWidget {
  final ScanResultModel result;
  const _ScanSuccessView({required this.result});

  @override
  State<_ScanSuccessView> createState() => _ScanSuccessViewState();
}

class _ScanSuccessViewState extends State<_ScanSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _checkScale;
  late final Animation<double> _progress;

  double get _progressValue {
    final r = widget.result;
    if (r.program.mode == "stamps" &&
        r.stampsTarget != null &&
        r.stampsTarget! > 0) {
      return (r.stamps / r.stampsTarget!).clamp(0, 1).toDouble();
    }
    if (r.program.mode == "points" &&
        r.rewardTarget != null &&
        r.rewardTarget! > 0) {
      return (r.points / r.rewardTarget!).clamp(0, 1).toDouble();
    }
    return 0;
  }

  bool get _showProgress {
    final r = widget.result;
    return (r.program.mode == "stamps" &&
            r.stampsTarget != null &&
            r.stampsTarget! > 0) ||
        (r.program.mode == "points" &&
            r.rewardTarget != null &&
            r.rewardTarget! > 0);
  }

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
    _progress = Tween<double>(begin: 0, end: _progressValue).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  final controller = MerchantDashboardController.to;
  String get _title {
    final r = widget.result;
    if (r.duplicate) return "already_scanned".tr;
    switch (r.action) {
      case "add_stamp":
        return "stamp_added".tr;
      case "add_point":
        return "points_added".tr;
      case "add_cashback":
        return "cashback_added".tr;
      default:
        return "scan_success".tr;
    }
  }

  String get _subtitle {
    final r = widget.result;
    if (r.duplicate) return "duplicate_scan_desc".tr;
    if (r.program.mode == "stamps") {
      return "stamps_awarded_desc".trParams({"count": r.awarded.toString()});
    }
    if (r.program.mode == "cashback") {
      return "cashback_awarded_desc"
          .trParams({"amount": r.awarded.toString()});
    }
    return "points_awarded_desc".trParams({"count": r.awarded.toString()});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.result;
    final accent = r.duplicate ? Colors.orangeAccent : AppColors.primary;

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
                                colors: [
                                  accent,
                                  accent.withValues(alpha: 0.75),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              r.duplicate
                                  ? Iconsax.warning_2
                                  : Iconsax.tick_circle,
                              color: Colors.white,
                              size: size.width * 0.09,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.026),

                    AppText(
                      _title,
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.008),
                    AppText(
                      _subtitle,
                      fontSize: size.width * 0.033,
                      textAlign: TextAlign.center,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),

                    /// ── PROGRESS ────────────────────
                    if (_showProgress) ...[
                      SizedBox(height: size.height * 0.024),
                      AnimatedBuilder(
                        animation: _progress,
                        builder: (context, _) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progress.value,
                            minHeight: 10,
                            backgroundColor: accent.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(accent),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.008),
                      AppText(
                        r.program.mode == "stamps"
                            ? "${r.stamps}/${r.stampsTarget} ${"stamps".tr}"
                            : "${r.points}/${r.rewardTarget} ${"points".tr}",
                        fontSize: size.width * 0.03,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ],

                    /// ── REWARD EARNED BANNER ────────
                    if (r.earnedReward != null) ...[
                      SizedBox(height: size.height * 0.02),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(size.width * 0.035),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.amber.withValues(alpha: 0.12),
                          border:
                              Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.gift, color: Colors.amber),
                            SizedBox(width: size.width * 0.025),
                            Expanded(
                              child: AppText(
                                "reward_earned".tr,
                                fontWeight: FontWeight.w700,
                                fontSize: size.width * 0.032,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: size.height * 0.03),

                    SizedBox(
                      width: double.infinity,
                      height: size.height * 0.062,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.back();
                          controller.fetchDashboardData() ;
                        } ,
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
    ));
  }
}