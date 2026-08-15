import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

Future<void> showRewardResultDialog(
  BuildContext context, {
  required bool success,
  String? title,
  String? message,
  VoidCallback? onDone,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      final color = success ? const Color(0xFF00C896) : Colors.redAccent;

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6 * anim.value, sigmaY: 6 * anim.value),
        child: FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.fromLTRB(26, 32, 26, 22),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── icon badge ──
                      Container(
                        height: 76,
                        width: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [color.withOpacity(.2), color.withOpacity(.06)],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [color, color.withOpacity(.75)],
                              ),
                              boxShadow: [
                                BoxShadow(color: color.withOpacity(.35), blurRadius: 16, offset: const Offset(0, 6)),
                              ],
                            ),
                            child: Icon(
                              success ? Iconsax.tick_circle : Iconsax.close_circle,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      AppText(
                        title ?? (success ? "agent_reward_validated_title".tr : "agent_reward_failed_title".tr),
                        textAlign: TextAlign.center,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),

                      const SizedBox(height: 8),

                      AppText(
                        message ?? (success ? "agent_reward_validated_generic".tr : "agent_reward_validate_failed".tr),
                        textAlign: TextAlign.center,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                      ),

                      const SizedBox(height: 26),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            onDone?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: AppText(
                            success ? "done".tr : "close".tr,
                            fontSize: 15,
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
      );
    },
  );
}