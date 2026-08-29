import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

Future<void> showWheelHistoryDetailDialog(
  BuildContext context, {
  required String label,
  required String companyName,
  required String type,
  required String value,
  required DateTime spunAt,
  String? code,
}) {
  final isPoints = type.toLowerCase() == 'points';
  final color = isPoints ? const Color(0xFFF59E0B) : const Color(0xFFE91E63);
  final typeIcon = isPoints ? Iconsax.coin : Iconsax.ticket_discount;
  final localeCode = Get.locale?.languageCode ?? 'en';
  final formattedDate = DateFormat('dd MMM yyyy · HH:mm', localeCode).format(spunAt.toLocal());

  return showGeneralDialog(
 context: context,
  barrierDismissible: true,
  barrierLabel: "dismiss",
  barrierColor: Colors.black.withOpacity(0.5),
  transitionDuration: const Duration(milliseconds: 300),
  pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
  transitionBuilder: (ctx, anim, sec, child) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6 * anim.value, sigmaY: 6 * anim.value),
        child: FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: .88, end: 1).animate(curved),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.25), blurRadius: 30, offset: const Offset(0, 14))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 68,
                        width: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [color, color.withOpacity(.7)]),
                          boxShadow: [BoxShadow(color: color.withOpacity(.4), blurRadius: 18, offset: const Offset(0, 8))],
                        ),
                        child: Icon(typeIcon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 16),
                      AppText(label, fontSize: 17, fontWeight: FontWeight.w800, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      AppText(
                        companyName,
                        fontSize: 12.5,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(30)),
                        child: AppText(
                          isPoints ? '+$value ${"points_label".tr}' : '$value%',
                          fontWeight: FontWeight.w800,
                          color: color,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.calendar_1_copy, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          AppText(formattedDate, fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                        ],
                      ),

                      // ── QR code, only when a reward code exists ──
                      if (code != null && code.isNotEmpty) ...[
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
                        height: 46,
                        child: Material(
                          color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(ctx).pop(),
                            child: Center(
                              child: AppText("close".tr, fontWeight: FontWeight.w700, fontSize: 13.5),
                            ),
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