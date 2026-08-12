import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/InvoicesController.dart';
import 'InvoiceTile.dart';

Future<void> showInvoiceListSheet(BuildContext context) {
  final controller = Get.find<InvoicesController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: .85,
        minChildSize: .5,
        maxChildSize: .95,
        expand: false,
        builder: (context, scrollController) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1F26) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Iconsax.receipt_item, size: 16, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        AppText("all_invoices".tr, fontSize: 16, fontWeight: FontWeight.w800),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (controller.loading.value && !controller.initialLoaded.value) {
                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: 5,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              height: 76,
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.white : Colors.black).withOpacity(.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        );
                      }

                      if (controller.hasError.value && controller.invoices.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Iconsax.warning_2, size: 36, color: Colors.redAccent),
                                const SizedBox(height: 14),
                                AppText("failed_load_invoices".tr, fontSize: 13.5, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
                                const SizedBox(height: 14),
                                InkWell(
                                  onTap: () => controller.fetchInvoices(reset: true),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
                                    child: AppText("retry".tr, fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (controller.invoices.isEmpty) {
                        return Center(
                          child: AppText(
                            "no_invoices_found".tr,
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                          ),
                        );
                      }

                      return NotificationListener<ScrollNotification>(
                        onNotification: (scroll) {
                          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 150) {
                            controller.loadMore();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.invoices.length + (controller.loadingMore.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == controller.invoices.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: LoadingAnimationWidget.fourRotatingDots(color: AppColors.primary, size: 30),
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InvoiceTile(invoice: controller.invoices[index]),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}