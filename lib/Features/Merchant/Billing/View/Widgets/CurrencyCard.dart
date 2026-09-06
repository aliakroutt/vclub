// lib/Features/Merchant/Billing/View/Widgets/CurrencyCard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/CurrencyController.dart';
import 'package:vclub/Features/Merchant/Billing/Models/CurrencyOption.dart';

class CurrencyCard extends StatelessWidget {
  const CurrencyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<CurrencyController>();

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .22 : .04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: size.width * .12,
            height: size.width * .12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(.7)],
              ),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 12, offset: const Offset(0, 6)),
              ],
            ),
            child: Icon(Iconsax.money_change, color: Colors.white, size: size.width * .056),
          ),
          SizedBox(width: size.width * .035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText("currency_card_title".tr, fontSize: size.width * .04, fontWeight: FontWeight.w700),
                const SizedBox(height: 3),
                AppText(
                  "currency_card_subtitle".tr,
                  fontSize: size.width * .03,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55),
                ),
              ],
            ),
          ),
          SizedBox(width: size.width * .02),
          Obx(() {
            final current = controller.currentCurrency;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _openCurrencyPicker(context, controller),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: size.width * .032, vertical: size.height * .011),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.primary.withOpacity(.10),
                    border: Border.all(color: AppColors.primary.withOpacity(.22)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (current != null) ...[
                        AppText(current.flagEmoji, fontSize: size.width * .04),
                        SizedBox(width: size.width * .014),
                        AppText(
                          current.currencyCode,
                          fontSize: size.width * .034,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ] else
                        AppText(
                          "select_currency".tr,
                          fontSize: size.width * .032,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      SizedBox(width: size.width * .012),
                      Icon(Iconsax.arrow_circle_down_copy, size: size.width * .038, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _openCurrencyPicker(BuildContext context, CurrencyController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CurrencyPickerSheet(controller: controller, isDark: isDark),
    );
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  final CurrencyController controller;
  final bool isDark;

  const _CurrencyPickerSheet({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151515) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 12, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: const Icon(Iconsax.money_change, size: 21, color: Colors.white),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText("select_currency".tr, fontSize: 17, fontWeight: FontWeight.w800),
                      const SizedBox(height: 3),
                      AppText(
                        "currency_picker_subtitle".tr,
                        fontSize: 12.5,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Obx(() {
  final current = controller.currentCurrency;
  final isLoading = controller.isChangingCurrency.value;
  final pending = controller.pendingOption.value;

  return Column(
    children: CurrencyOption.values.map((option) {
      final isSelected = current == option;
      final isThisPending = isLoading && pending == option;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isLoading || isSelected
                ? null
                : () async {
                    final success = await controller.changeCurrency(option);
                    if (success && context.mounted) Navigator.pop(context);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.14),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.025)),
                border: Border.all(
                  color: isSelected ? AppColors.primary.withOpacity(0.4) : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Opacity(
                opacity: (isLoading && !isThisPending) ? 0.4 : 1,
                child: Row(
                  children: [
                    AppText(option.flagEmoji, fontSize: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            option.labelKey.tr,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          AppText(
                            "${option.currencyCode} • ${option.symbol}",
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    if (isThisPending)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    else if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Iconsax.tick_circle, color: Colors.white, size: 14),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}),
          ],
        ),
      ),
    );
  }
}