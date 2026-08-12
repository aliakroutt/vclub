import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/InvoicesController.dart';
import 'InvoiceListSheet.dart';
import 'InvoiceTile.dart';

class InvoiceHistoryCard extends StatelessWidget {
  const InvoiceHistoryCard({super.key});

  static const _accent = Color(0xFF7C6FF7);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<InvoicesController>()) {
      Get.put(InvoicesController());
    }

    final controller = Get.find<InvoicesController>();
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: isDark ? Colors.white.withOpacity(.07) : Colors.black.withOpacity(.06)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? .28 : .055), blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: _accent.withOpacity(.05), blurRadius: 40, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: size.width * .105,
                height: size.width * .105,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _accent.withOpacity(.18)),
                ),
                child: Icon(Iconsax.receipt_item, color: _accent, size: size.width * .050),
              ),
              SizedBox(width: size.width * .035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText("invoice_history_title".tr, fontSize: size.width * .042, fontWeight: FontWeight.w800),
                    SizedBox(height: size.height * .003),
                    AppText(
                      "invoice_history_subtitle".tr,
                      fontSize: size.width * .030,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white.withOpacity(.35) : Colors.black.withOpacity(.38),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .024),

          Obx(() {
            if (controller.loading.value && !controller.initialLoaded.value) {
              return Column(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      height: size.height * .088,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              );
            }

            if (controller.hasError.value && controller.invoices.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Iconsax.warning_2, size: 30, color: Colors.redAccent),
                      const SizedBox(height: 10),
                      AppText("failed_load_invoices".tr, fontSize: 12.5, color: Colors.redAccent, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            if (controller.invoices.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: AppText(
                    "no_invoices_found".tr,
                    fontSize: 12.5,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                  ),
                ),
              );
            }

            final preview = controller.invoices.take(3).toList();

            return Column(
              children: [
                ...List.generate(preview.length, (i) {
                  final isLast = i == preview.length - 1;
                  return Column(
                    children: [
                      InvoiceTile(invoice: preview[i]),
                      if (!isLast)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: size.height * .013),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark ? Colors.white.withOpacity(.055) : Colors.black.withOpacity(.05),
                          ),
                        ),
                    ],
                  );
                }),

                if (controller.total > 3) ...[
                  SizedBox(height: size.height * .018),
                  InkWell(
                    onTap: () => showInvoiceListSheet(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText("view_all_invoices".tr, fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Icon(Iconsax.arrow_circle_right_copy, size: 14, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}