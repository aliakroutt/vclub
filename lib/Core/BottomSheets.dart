import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

void showLogoutBottomSheet({
  required VoidCallback onConfirm,
}) {
  final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
  final isRTL = Get.locale?.languageCode == 'ar';
  final size = MediaQuery.of(Get.context!).size;

  Get.bottomSheet(
    Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(child:  Container(
        padding: EdgeInsets.all(size.width * 0.05),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// TOP INDICATOR
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            /// ICON
            Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.12),
              ),
              child: const Icon(
                Iconsax.logout,
                color: Colors.red,
                size: 28,
              ),
            ),

            SizedBox(height: size.height * 0.02),

            /// TITLE
            AppText(
              "logout_title".tr,
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: size.height * 0.01),

            /// DESCRIPTION
            Padding(
              padding:  EdgeInsets.symmetric(horizontal:size.width * 0.03 ),
              child: AppText(
                "logout_desc".tr,
                fontSize: size.width * 0.035,
                textAlign: TextAlign.center,
                color: Theme.of(Get.context!)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ),

            SizedBox(height: size.height * 0.03),

            /// BUTTONS
            Row(
              children: [
                /// CANCEL
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.02,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: AppText(
                          "cancel".tr,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: size.width * 0.03),

                /// CONFIRM
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.02,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            Colors.red,
                            Colors.redAccent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Center(
                        child: AppText(
                          "logout".tr,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}