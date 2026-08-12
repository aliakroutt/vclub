import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/PlansController.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/SmsAddonController.dart';
import 'package:vclub/Features/Merchant/Billing/Models/ChangePlanModel.dart';
import 'package:vclub/Features/Merchant/Billing/Models/PlanModel.dart';
import 'package:vclub/Features/Merchant/Billing/Models/SmsAddonModel.dart';

Future<ChangePlanResult?> showChangePlanConfirmSheet(BuildContext context, PlanDisplayModel plan) async {
  final plansController = Get.find<PlansController>();
  final smsController = Get.find<SmsAddonController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final RxBool smsSelected = smsController.enabled.value.obs;

  final result = await showModalBottomSheet<ChangePlanResult?>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primary.withOpacity(.7)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Iconsax.crown_1, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText("confirm_plan_change_title".tr, fontSize: 16, fontWeight: FontWeight.w800),
                        const SizedBox(height: 3),
                        AppText(
                          "${"you_are_choosing".tr} ${plan.features.titleKey.tr}",
                          fontSize: 12.5,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── PRICE SUMMARY (plan + optional SMS breakdown) ──
              Obx(() {
                final smsInfo = smsController.info.value;
                final showSmsLine = smsSelected.value && smsInfo != null;
                final total = plan.price.amountValue + (showSmsLine ? smsInfo.amountValue : 0);

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(.2)),
                  ),
                  child: Column(
                    children: [
                      _PriceRow(
                        label: plan.features.titleKey.tr,
                        value: formatMoney(plan.price.amountValue, plan.price.currency),
                      ),
                      if (showSmsLine) ...[
                        const SizedBox(height: 8),
                        _PriceRow(
                          label: "sms_option_title".tr,
                          value: "+ ${formatMoney(smsInfo.amountValue, smsInfo.currency)}",
                          valueColor: AppColors.primary,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Divider(height: 1, color: AppColors.primary.withOpacity(.15)),
                      const SizedBox(height: 10),
                      _PriceRow(
                        label: "total_due_label".tr,
                        value: "${formatMoney(total, plan.price.currency)} / ${"month".tr}",
                        bold: true,
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 18),

              Obx(() => Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.025),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: smsSelected.value ? AppColors.primary.withOpacity(.3) : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Iconsax.sms_notification, size: 18, color: AppColors.primary),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText("include_sms_option".tr, fontSize: 13, fontWeight: FontWeight.w700),
                                  const SizedBox(height: 2),
                                  AppText(
                                    "include_sms_option_subtitle".tr,
                                    fontSize: 11,
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: smsSelected.value,
                              activeColor: AppColors.primary,
                              onChanged: (v) => smsSelected.value = v,
                            ),
                          ],
                        ),

                        // ── inline reminder of the SMS charge, shown only when toggled on ──
                        if (smsSelected.value && smsController.info.value != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.info_circle, size: 14, color: AppColors.primary),
                                const SizedBox(width: 7),
                                Expanded(
                                  child: AppText(
                                    "${"sms_addon_charge_notice".tr} ${formatMoney(smsController.info.value!.amountValue, smsController.info.value!.currency)} / ${"month".tr}.",
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )),

              const SizedBox(height: 22),

              Obx(() {
                final loading = plansController.isChangingPlan.value;

                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: loading
                          ? null
                          : () async {
                              final res = await plansController.changePlan(
                                plan: plan.price.key,
                                sms: smsSelected.value,
                              );
                              if (sheetContext.mounted) Navigator.pop(sheetContext, res);
                            },
                      child: Center(
                        child: loading
                            ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 26)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Iconsax.card_pos, size: 17, color: Colors.white),
                                  const SizedBox(width: 8),
                                  AppText("continue_to_payment".tr, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                                ],
                              ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext, null),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1)),
                  ),
                  child: AppText("cancel".tr, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  return result;
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText(
            label,
            fontSize: bold ? 13.5 : 12.5,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: bold ? null : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.7),
          ),
        ),
        AppText(
          value,
          fontSize: bold ? 16 : 12.5,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
          color: valueColor,
        ),
      ],
    );
  }
}