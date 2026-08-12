import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/SmsAddonController.dart';
import 'package:vclub/Features/Merchant/Billing/Models/SmsAddonModel.dart';
import 'SmsAddonConfirmSheet.dart';

class SmsAddonCard extends StatelessWidget {
  const SmsAddonCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SmsAddonController>()) {
      Get.put(SmsAddonController());
    }

    final controller = Get.find<SmsAddonController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Future<void> handleToggle(bool value) async {
      final confirmed = await showSmsAddonConfirmSheet(
        context,
        activating: value,
        info: controller.info.value,
      );
      if (!confirmed) return;

      final result = await controller.toggle(value);

      if (!context.mounted) return;

      if (result == null) {
        AppSnackBar.error("sms_toggle_failed".tr);
        return;
      }

      AppSnackBar.success(
        result.enabled ? "sms_activated_success".tr : "sms_deactivated_success".tr,
      );
     await controller.refreshProfile();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(.07) : Colors.black.withOpacity(.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .3 : .05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primary.withOpacity(.7)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(Iconsax.sms_notification, color: Colors.white, size: 21),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText("sms_option_title".tr, fontSize: 15.5, fontWeight: FontWeight.w800),
                    
                    
                  ],
                ),
              ),
              const SizedBox(width: 8),
             
              Obx(() {
                if (controller.toggling.value) {
                  return SizedBox(
                    height: 26,
                    width: 26,
                    child: LoadingAnimationWidget.fourRotatingDots(color: AppColors.primary, size: 22),
                  );
                }

                return Switch.adaptive(
                  value: controller.enabled.value,
                  activeColor: AppColors.primary,
                  onChanged: handleToggle,
                );
              }),
            ],
          ),
          const SizedBox(height: 14),
          AppText(
                      "sms_option_subtitle".tr,
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                    ),
                    
          const SizedBox(height: 14),
          Divider(height: 1, color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
          const SizedBox(height: 14),

          Obx(() {
            if (controller.loadingInfo.value) {
              return Row(
                children: [
                  LoadingAnimationWidget.fourRotatingDots(color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  AppText(
                    "loading_price".tr,
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                  ),
                ],
              );
            }

            final info = controller.info.value;
            if (controller.hasError.value || info == null) {
              return Row(
                children: [
                  Icon(Iconsax.warning_2, size: 14, color: Colors.redAccent.withOpacity(.7)),
                  const SizedBox(width: 8),
                  AppText("failed_load_price".tr, fontSize: 12, color: Colors.redAccent),
                ],
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.tag_2, size: 16, color: AppColors.primary),
                  const SizedBox(width: 9),
                  Expanded(
                    child: AppText(
                      "${formatMoney(info.amountValue, info.currency)} ${"per_month".tr}",
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: AppText(
                      "sms_channel".tr,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),
          AppText(
            "sms_option_extra_note".tr,
            fontSize: 11.5,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55),
          ),
        ],
      ),
    );
  }
}