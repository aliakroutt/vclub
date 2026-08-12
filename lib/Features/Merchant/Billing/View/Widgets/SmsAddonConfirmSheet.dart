import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Models/SmsAddonModel.dart';

Future<bool> showSmsAddonConfirmSheet(
  BuildContext context, {
  required bool activating,
  required SmsAddonInfoModel? info,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final color = activating ? AppColors.primary : Colors.redAccent;

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
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
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(.18), color.withOpacity(.06)],
                  ),
                ),
                child: Icon(
                  activating ? Iconsax.message_notif : Iconsax.message_remove,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 18),
              AppText(
                activating ? "enable_sms_title".tr : "disable_sms_title".tr,
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              AppText(
                activating ? "enable_sms_subtitle".tr : "disable_sms_subtitle".tr,
                fontSize: 13,
                textAlign: TextAlign.center,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
              ),
              if (activating && info != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(.2)),
                  ),
                  child: Center(
                    child: AppText(
                      "${formatMoney(info.amountValue, info.currency)} ${"per_month".tr}",
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1)),
                      ),
                      child: AppText("cancel".tr, fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: AppText(
                        activating ? "activate".tr : "deactivate".tr,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return confirmed ?? false;
}