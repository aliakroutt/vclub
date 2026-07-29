import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Features/Merchant/Main/Controllers/MerchantMainController.dart';

class MerchantMainDrawer extends StatelessWidget {
  final MerchantMainController controller;
  final ThemeService themeService;

  const MerchantMainDrawer({
    super.key,
    required this.controller,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primary = AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark
          ? const Color(0xFF0E0E10)
          : const Color(0xFFF8F8FB),
      child: SafeArea(
        child: Column(
          children: [
            /// ───────────────── HEADER (PREMIUM) ─────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(size.width * 0.045),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(.06)
                        : Colors.black.withOpacity(.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? .25 : .04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ── AVATAR ─────────────────────────────────────────────
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withOpacity(.10),
                      ),
                      child: Icon(Iconsax.shop, color: primary, size: 24),
                    ),

                    SizedBox(width: size.width * 0.035),

                    // ── TEXT ───────────────────────────────────────────────
                    // ── TEXT ───────────────────────────────────────────────
                    Expanded(
                      child: Obx(() {
                        final merchant = MerchantController.to.merchant.value;
                        final companyName = merchant?.company?.name;
                        final fullName = merchant != null
                            ? "${merchant.firstName} ${merchant.lastName}"
                                  .trim()
                            : "";

                        final displayName =
                            (companyName != null && companyName.isNotEmpty)
                            ? companyName
                            : (fullName.isNotEmpty ? fullName : "My Business");

                        final displayEmail =
                            merchant?.email ?? "merchant@email.com";

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              displayName,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              displayEmail,
                              fontSize: 12.5,
                              color: Colors.grey,
                            ),
                          ],
                        );
                      }),
                    ),

                    // ── MERCHANT BADGE ───────────────────────────────────────
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// ───────────────── MENU ─────────────────
            Expanded(
              child: Obx(() {
                return Padding(
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _item(
                        context,
                        Iconsax.home_2,
                        "dashboard_merchant".tr,
                        0,
                      ),

                      _sectionTitle(context, "loyalty_program_merchant".tr),
                      _item(
                        context,
                        Iconsax.crown,
                        "create_manage_loyalty_merchant".tr,
                        1,
                      ),
                      _item(context, Iconsax.gift, "rewards_merchant".tr, 2),
                      _item(
                        context,
                        Iconsax.cup,
                        "fortune_wheel_merchant".tr,
                        3,
                      ),

                      _sectionTitle(context, "users_merchant".tr),
                      _item(
                        context,
                        Iconsax.people,
                        "employees_merchant".tr,
                        4,
                      ),
                      _item(
                        context,
                        Iconsax.profile_2user,
                        "clients_merchant".tr,
                        5,
                      ),

                      _sectionTitle(context, "marketing_merchant".tr),
                      _item(
                        context,
                        Iconsax.send_2,
                        "campaigns_merchant".tr,
                        6,
                      ),
                      _item(
                        context,
                        Iconsax.chart_2,
                        "analytics_merchant".tr,
                        7,
                      ),
                      _item(
                        context,
                        Iconsax.google_copy,
                        "google_reviews_merchant".tr,
                        8,
                      ),

                      _sectionTitle(context, "account_merchant".tr),
                      _item(
                        context,
                        Iconsax.setting_2,
                        "settings_merchant".tr,
                        9,
                      ),
                      _item(
                        context,
                        Iconsax.wallet_3,
                        "billing_merchant".tr,
                        10,
                      ),
                    ],
                  ),
                );
              }),
            ),

            /// ───────────────── LOGOUT (PREMIUM BUTTON) ─────────────────
            Padding(
              padding: EdgeInsets.all(size.width * 0.04),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.red.withOpacity(.08),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(.08),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.logout,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      AppText(
                        "logout".tr,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ───────────────── SECTION TITLE ─────────────────
  Widget _sectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 18, bottom: 8),
      child: AppText(
        title.toUpperCase(),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isDark
            ? Colors.white.withOpacity(.35)
            : Colors.black.withOpacity(.35),
        letterSpacing: 0.6,
      ),
    );
  }

  /// ───────────────── ITEM (PREMIUM STYLE) ─────────────────
  Widget _item(BuildContext context, IconData icon, String title, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = controller.selectedIndex.value == index;
    final primary = AppColors.primary;

    return GestureDetector(
      onTap: () {
        controller.selectIndex(index);
        Get.back();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [BoxShadow(color: primary.withOpacity(.10), blurRadius: 12)]
              : [],
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? primary.withOpacity(.12)
                    : (isDark
                          ? Colors.white.withOpacity(.04)
                          : Colors.grey.withOpacity(.08)),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? primary : Colors.grey,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: AppText(
                title,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
