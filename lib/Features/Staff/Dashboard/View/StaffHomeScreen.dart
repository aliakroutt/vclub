import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Storage/Controllers/AgentController.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/QRScanner/QrSCanner.dart';
import 'package:vclub/Features/Staff/Dashboard/View/Widgets/ValidateRewardSheet.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * .015),

              // ── HEADER ──
              Align(
                alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                child: Obx(() {
                  final agent = AgentController.to.agent.value;
                  final firstName = agent?.firstName ?? "";
                  final displayName = firstName.isNotEmpty
                      ? firstName
                      : "there";

                  return FadeSlide(
                    delayMs: 150,
                    child: AppText(
                      "staff_greeting".trParams({"name": displayName}),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                child: FadeSlide(
                  delayMs: 200,
                  child: AppText(
                    "staff_greeting_subtitle".tr,
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(.65),
                  ),
                ),
              ),

              SizedBox(height: size.height * .035),

              // ── ACTION CARDS ──
              FadeSlide(
                delayMs: 260,
                child: _StaffActionCard(
                  icon: Iconsax.scan,
                  title: "staff_scan_client_title".tr,
                  subtitle: "staff_scan_client_subtitle".tr,
                  gradientColors: const [Color(0xFF6C5CE7), Color(0xFF8B7EFF)],
                  onTap: () =>
                      Get.to(() => const QrScannerMerchant(isRedeem: false)),
                ),
              ),

              const SizedBox(height: 16),

              FadeSlide(
                delayMs: 320,
                child: _StaffActionCard(
                  icon: Iconsax.gift,
                  title: "staff_validate_reward_title".tr,
                  subtitle: "staff_validate_reward_subtitle".tr,
                  gradientColors: const [Color(0xFFFFB930), Color(0xFFFFCB61)],
                  onTap: () => showValidateRewardSheet(context),
                ),
              ),
              SizedBox(height: size.height * .03),

              // ── PERMISSIONS CARD ──
              FadeSlide(delayMs: 400, child: _PermissionsCard()),

              SizedBox(height: size.height * .04),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _StaffActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(.07)
                  : Colors.black.withOpacity(.05),
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withOpacity(isDark ? .18 : .12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? .25 : .04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, fontSize: 15.5, fontWeight: FontWeight.w800),
                    const SizedBox(height: 4),
                    AppText(
                      subtitle,
                      fontSize: 12.5,
                      height: 1.35,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    .05,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.arrow_circle_right_copy,
                  size: 16,
                  color: gradientColors.first,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(isDark ? .16 : .08),
            AppColors.primary.withOpacity(isDark ? .05 : .03),
          ],
        ),
        border: Border.all(color: AppColors.primary.withOpacity(.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(.7)],
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Iconsax.shield_tick,
              color: Colors.white,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  "staff_permissions_title".tr,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
                const SizedBox(height: 4),
                AppText(
                  "staff_permissions_subtitle".tr,
                  fontSize: 12,
                  height: 1.4,
                  color: isDark
                      ? Colors.white.withOpacity(.55)
                      : Colors.black.withOpacity(.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
