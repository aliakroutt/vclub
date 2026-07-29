import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Settings/Controllers/SettingsController.dart';

class OnlinePresenceCard extends StatelessWidget {
  OnlinePresenceCard({super.key});

  final controller = Get.find<SettingsController>();

  static const _accent = Color(0xFF6C5CE7);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.06)
              : Colors.black.withOpacity(.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .22 : .04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── HEADER ─────────────────────────────
          Row(
            children: [
              Container(
                width: size.width * .105,
                height: size.width * .105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _accent.withOpacity(.10),
                ),
                child: Icon(
                  Iconsax.global,
                  color: _accent,
                  size: size.width * .052,
                ),
              ),
              SizedBox(width: size.width * .035),
              Expanded(
                child: AppText(
                  "online_presence".tr,
                  fontSize: size.width * .042,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .025),

          /// ── LOGO UPLOAD ───────────────────────
          /// ── LOGO UPLOAD (MODERN PREMIUM) ───────────────────────
          Obx(() {
            final file = controller.logoFile.value;

            return GestureDetector(
              onTap: controller.pickLogo,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding: EdgeInsets.all(size.width * .04),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark
                      ? Colors.white.withOpacity(.03)
                      : Colors.black.withOpacity(.02),
                  border: Border.all(
                    color: file != null
                        ? const Color(0xFF6C5CE7).withOpacity(.35)
                        : (isDark
                              ? Colors.white.withOpacity(.06)
                              : Colors.black.withOpacity(.05)),
                  ),
                ),
                child: Row(
                  children: [
                    /// LEFT PREVIEW / PLACEHOLDER
                    Container(
                      width: size.width * .16,
                      height: size.width * .16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark
                            ? Colors.white.withOpacity(.05)
                            : Colors.black.withOpacity(.03),
                        image: file != null
                            ? DecorationImage(
                                image: FileImage(file),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: file == null
                          ? Icon(
                              Iconsax.image,
                              size: size.width * .065,
                              color: Colors.grey,
                            )
                          : null,
                    ),

                    SizedBox(width: size.width * .04),

                    /// TEXT BLOCK
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            "logo".tr,
                            fontSize: size.width * .036,
                            fontWeight: FontWeight.w700,
                          ),

                          const SizedBox(height: 4),

                          AppText(
                            file == null
                                ? "upload_logo_hint".tr
                                : "replace_logo_hint".tr,
                            fontSize: size.width * .030,
                            color: Colors.grey,
                          ),

                          if (file != null) ...[
                            const SizedBox(height: 8),
                            AppText(
                              "tap_to_change_logo".tr,
                              fontSize: size.width * .028,
                              color: const Color(0xFF6C5CE7),
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ],
                      ),
                    ),

                    /// ACTION ICON
                    Container(
                      width: size.width * .10,
                      height: size.width * .10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF6C5CE7).withOpacity(.10),
                      ),
                      child: Icon(
                        file == null ? Iconsax.cloud_plus : Iconsax.refresh,
                        color: const Color(0xFF6C5CE7),
                        size: size.width * .05,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: size.height * .02),

          /// ── GOOGLE REVIEW LINK ────────────────
          _Field(
            controller: controller.googleReviewController,
            label: "google_review_link".tr,
            icon: Iconsax.link,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: size.width * .031,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),

        SizedBox(height: 6),

        Container(
          height: size.height * .06,
          padding: EdgeInsets.symmetric(horizontal: size.width * .03),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark
                ? Colors.white.withOpacity(.03)
                : Colors.black.withOpacity(.02),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(.06)
                  : Colors.black.withOpacity(.05),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF6C5CE7)),
              SizedBox(width: size.width * .03),

              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: size.width * .034,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
