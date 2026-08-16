import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/FortuneWheel/Models/FortuneWheelModels.dart';

Future<void> showWheelResultDialog(BuildContext context, WheelSpinResult result) {
  final isWin = result.prize.type != WheelSegmentType.noWin;
  final color = isWin ? const Color(0xFF00C896) : Colors.grey;

  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, sec, child) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final curved = CurvedAnimation(parent: anim, curve: Curves.elasticOut);

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6 * anim.value, sigmaY: 6 * anim.value),
        child: FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: .7, end: 1).animate(curved),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.fromLTRB(26, 30, 26, 22),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.25), blurRadius: 30, offset: const Offset(0, 14))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 78,
                        width: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [color, color.withOpacity(.7)]),
                          boxShadow: [BoxShadow(color: color.withOpacity(.4), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Icon(isWin ? result.prize.type.icon : Icons.sentiment_neutral_rounded, color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 18),
                      AppText(
                        isWin ? "wheel_win_title".tr : "wheel_no_win_title".tr,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      AppText(result.prize.label, fontSize: 14, fontWeight: FontWeight.w600, textAlign: TextAlign.center),
                      if (result.prize.code != null && result.prize.code!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
                          child: AppText(result.prize.code!, fontWeight: FontWeight.w800, color: color, letterSpacing: 1),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                          child: AppText("done".tr, color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}