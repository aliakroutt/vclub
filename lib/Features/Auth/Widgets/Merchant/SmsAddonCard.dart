// lib/Features/Auth/Widgets/Merchant/SmsAddonCard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class SmsAddonCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const SmsAddonCard({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(size.width * 0.045),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.14),
                    AppColors.primary.withOpacity(0.05),
                  ],
                )
              : null,
          color: isSelected ? null : Theme.of(context).cardColor,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.14)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 18 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ICON BADGE ──
            Container(
              width: size.width * 0.13,
              height: size.width * 0.13,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(Iconsax.sms_notification, color: Colors.white, size: size.width * 0.06),
            ),

            SizedBox(width: size.width * 0.035),

            // ── TEXT ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          "sms_addon_title".tr,
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      AppText(
                        "sms_addon_price".tr,
                        fontSize: size.width * 0.038,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.008),
                  AppText(
                    "sms_addon_description".tr,
                    fontSize: size.width * 0.032,
                    height: 1.4,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ],
              ),
            ),

            SizedBox(width: size.width * 0.02),

            // ── TOGGLE / CHECK ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size.width * 0.065,
              height: size.width * 0.065,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: 1.6,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: size.width * 0.045, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}