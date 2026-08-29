import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/Rewards/Models/ClientReviewRewardModel.dart';

Future<void> showWriteReviewResultDialog(
  BuildContext context, {
  required bool success,
  ReviewClaimModel? claim,
  String? message,
}) {
  final color = success ? const Color(0xFF00C896) : Colors.redAccent;
  final rewardName = claim?.reward?.name;
  final code = claim?.code;

  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, sec, child) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6 * anim.value, sigmaY: 6 * anim.value),
        child: FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: .85, end: 1).animate(curved),
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
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [color, color.withOpacity(.7)]),
                          boxShadow: [BoxShadow(color: color.withOpacity(.4), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Icon(success ? Iconsax.tick_circle : Iconsax.close_circle, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 18),
                      AppText(
                        success ? "review_reward_claimed_title".tr : "review_reward_failed_title".tr,
                        fontSize: 17.5,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        message ??
                            (success
                                ? (rewardName != null && rewardName.isNotEmpty
                                    ? "review_reward_claimed_message_named".trParams({"reward": rewardName})
                                    : "review_reward_claimed_message".tr)
                                : "review_reward_failed_message".tr),
                        fontSize: 13.5,
                        textAlign: TextAlign.center,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                        height: 1.4,
                      ),

                      // ── QR code of the reward code, only on success ──
                      if (success && code != null && code.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: color.withOpacity(.2), width: 1.4),
                          ),
                          child: QrImageView(
                            data: code,
                            version: QrVersions.auto,
                            size: 150,
                            eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: color),
                            dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
                          child: AppText(code, fontWeight: FontWeight.w800, color: color, letterSpacing: 1, fontSize: 13),
                        ),
                      ],

                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
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