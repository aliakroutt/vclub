import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Auth/Widgets/BackgroundCercle.dart';

class PremiumSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const PremiumSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primary = AppColors.primary;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151515) : Colors.white,
        borderRadius: BorderRadius.circular(26),

        /// softer border in dark mode
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : primary.withOpacity(.12),
        ),

        /// adaptive shadow
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ]
            : [
                BoxShadow(
                  color: primary.withOpacity(.08),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            /// ===== BACKGROUND CIRCLES =====
            Positioned(
              top: -70,
              right: Get.locale?.languageCode == 'ar' ? null : -70,
              left: Get.locale?.languageCode == 'ar' ? -70 : null,
              child: IgnorePointer(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BackgroundCircle(
                      size: size.width * 0.42,
                      innerSize: size.width * 0.32,
                    ),
                    BackgroundCircle(
                      size: size.width * 0.22,
                      innerSize: size.width * 0.12,
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: -50,
              left: Get.locale?.languageCode == 'ar' ? null : -50,
              right: Get.locale?.languageCode == 'ar' ? -50 : null,
              child: IgnorePointer(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withOpacity(
                      isDark ? 0.02 : 0.03,
                    ),
                  ),
                ),
              ),
            ),

            /// ===== CONTENT =====
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: primary.withOpacity(
                            isDark ? 0.15 : 0.12,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: primary,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              title,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              subtitle,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}