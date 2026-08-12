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

 bool get _isStarterPlan =>
      (MerchantController.to.merchant.value?.company?.stripePlan ?? '').toUpperCase() == 'STARTER';

  bool get _isBusinessPlan =>
      (MerchantController.to.merchant.value?.company?.stripePlan ?? '').toUpperCase() == 'BUSINESS';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primary = AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0E0E10) : const Color(0xFFF8F8FB),
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
                    color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05),
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
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: primary.withOpacity(.10)),
                      child: Icon(Iconsax.shop, color: primary, size: 24),
                    ),
                    SizedBox(width: size.width * 0.035),
                    Expanded(
                      child: Obx(() {
                        final merchant = MerchantController.to.merchant.value;
                        final companyName = merchant?.company?.name;
                        final fullName = merchant != null ? "${merchant.firstName} ${merchant.lastName}".trim() : "";

                        final displayName = (companyName != null && companyName.isNotEmpty)
                            ? companyName
                            : (fullName.isNotEmpty ? fullName : "My Business");

                        final displayEmail = merchant?.email ?? "merchant@email.com";

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(displayName, fontSize: 16, fontWeight: FontWeight.w700),
                            const SizedBox(height: 4),
                            AppText(displayEmail, fontSize: 12.5, color: Colors.grey),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// ───────────────── MENU ─────────────────
            Expanded(
  child: Obx(() {
    final isFreePlan = MerchantController.to.isFreePlan;
    final isStarter = _isStarterPlan;
    final isBusiness = _isBusinessPlan;

    if (isFreePlan) {
      return Padding(
        padding: EdgeInsets.all(size.width * 0.01),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            _sectionTitle(context, "account_merchant".tr),
            _item(context, Iconsax.wallet_3, "billing_merchant".tr, 11),

            const SizedBox(height: 8),
            const _NoPlanNotice(),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(size.width * 0.01),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _item(context, Iconsax.home_2, "dashboard_merchant".tr, 0),

          _sectionTitle(context, "loyalty_program_merchant".tr),
          _item(context, Iconsax.crown, "create_manage_loyalty_merchant".tr, 1),
          _item(context, Iconsax.gift, "rewards_merchant".tr, 2),
          _item(context, Iconsax.cup, "fortune_wheel_merchant".tr, 3, locked: isStarter),

          _sectionTitle(context, "users_merchant".tr),
          _item(context, Iconsax.people, "employees_merchant".tr, 4, locked: isStarter || isBusiness),
          _item(context, Iconsax.profile_2user, "clients_merchant".tr, 5),

          _sectionTitle(context, "marketing_merchant".tr),
          _item(context, Iconsax.send_2, "campaigns_merchant".tr, 6, locked: isStarter),
          _item(context, Iconsax.chart_2, "analytics_merchant".tr, 7),
          _item(context, Iconsax.notification, "notifications".tr, 8, locked: isStarter),
          _item(context, Iconsax.google_copy, "google_reviews_merchant".tr, 9),

          _sectionTitle(context, "traceability_merchant".tr),
          _item(context, Iconsax.activity, "activity_merchant".tr, 12, locked: isStarter || isBusiness),
          _item(context, Iconsax.receipt_2_1, "redemptions_merchant".tr, 13, locked: isStarter || isBusiness),
          _item(context, Iconsax.document_text_1, "audit_merchant".tr, 14, locked: isStarter || isBusiness),

          _sectionTitle(context, "account_merchant".tr),
          _item(context, Iconsax.setting_2, "settings_merchant".tr, 10),
          _item(context, Iconsax.wallet_3, "billing_merchant".tr, 11),
        ],
      ),
    );
  }),
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
        color: isDark ? Colors.white.withOpacity(.35) : Colors.black.withOpacity(.35),
        letterSpacing: 0.6,
      ),
    );
  }

  /// ───────────────── ITEM (PREMIUM STYLE, WITH LOCKED STATE) ─────────────────
  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    int index, {
    bool locked = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = !locked && controller.selectedIndex.value == index;
    final primary = AppColors.primary;

    return GestureDetector(
      onTap: () {
        if (locked) {
          _showLockedNotice(context);
          return;
        }
        controller.selectIndex(index);
        Get.back();
      },
      child: Opacity(
        opacity: locked ? .45 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected ? [BoxShadow(color: primary.withOpacity(.10), blurRadius: 12)] : [],
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
                      : (isDark ? Colors.white.withOpacity(.04) : Colors.grey.withOpacity(.08)),
                ),
                child: Icon(icon, size: 20, color: isSelected ? primary : Colors.grey),
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
              if (locked)
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.lock_1, size: 12, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLockedNotice(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1F26) : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primary.withOpacity(.7)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 14, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: const Icon(Iconsax.lock_1, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 16),
                AppText(
                  "feature_locked_title".tr,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                AppText(
                  "feature_locked_subtitle".tr,
                  fontSize: 12.5,
                  textAlign: TextAlign.center,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        controller.selectIndex(11); // Billing
                        Get.back(); // close drawer
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.crown_1, size: 17, color: Colors.white),
                          const SizedBox(width: 8),
                          AppText("upgrade_plan_action".tr, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: AppText("close".tr, fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NoPlanNotice extends StatelessWidget {
  const _NoPlanNotice();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(isDark ? .18 : .1),
            AppColors.primary.withOpacity(isDark ? .05 : .03),
          ],
        ),
        border: Border.all(color: AppColors.primary.withOpacity(.22)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(.12), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primary.withOpacity(.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: const Icon(Iconsax.crown_1, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText("no_plan_notice_title".tr, fontSize: 13, fontWeight: FontWeight.w800),
                    const SizedBox(height: 3),
                    AppText(
                      "no_plan_notice_subtitle".tr,
                      fontSize: 11.5,
                      height: 1.35,
                      color: isDark ? Colors.white.withOpacity(.55) : Colors.black.withOpacity(.55),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: () {
                  Get.find<MerchantMainController>().selectIndex(11);
                  Get.back();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText("view_plans_action".tr, fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    const SizedBox(width: 5),
                    const Icon(Iconsax.arrow_circle_right_copy, size: 13, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}