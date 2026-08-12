import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart' as iconsax;
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/PlansController.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/SmsAddonController.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/BillingCheckoutWebViewScreen.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/ChangePlanConfirmSheet.dart';
import 'PlanCard.dart';
import 'PlansShimmerList.dart';

Future<void> showChangePlanSheet(BuildContext context) {
  if (!Get.isRegistered<PlansController>()) {
    Get.put(PlansController());
  }

  final controller = Get.find<PlansController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: .88,
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.primary.withOpacity(.75)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 12, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: const Icon(iconsax.Iconsax.crown_1, size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText("choose_your_plan".tr, fontSize: 17, fontWeight: FontWeight.w800),
                              const SizedBox(height: 3),
                              AppText(
                                "choose_your_plan_subtitle".tr,
                                fontSize: 12.5,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: Obx(() {
                      if (controller.loading.value && !controller.initialLoaded.value) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: const PlansShimmerList(),
                        );
                      }

                      if (controller.hasError.value && controller.plans.isEmpty) {
                        return _ErrorState(onRetry: controller.fetchPlans);
                      }

                      if (controller.plans.isEmpty) {
                        return Center(
                          child: AppText(
                            "no_plans_found".tr,
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                          ),
                        );
                      }

                      final currentPlanKey = MerchantController.to.merchant.value?.company?.stripePlan;

                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.plans.length,
                        itemBuilder: (context, index) {
                          final plan = controller.plans[index];
                          final isCurrent = currentPlanKey != null &&
                              currentPlanKey.toUpperCase() == plan.price.key.toUpperCase();

                          return PlanCard(
                            plan: plan,
                            isCurrent: isCurrent,
                            onSelect: () async {
                              final result = await showChangePlanConfirmSheet(context, plan);
                              if (result == null) return;
                              if (!context.mounted) return;

                              if (result.requiresPayment && result.url != null && result.url!.isNotEmpty) {
                                Navigator.pop(sheetContext);
                                Get.to(() => BillingCheckoutWebViewScreen(checkoutUrl: result.url!));
                              } else {
                                await Get.find<SmsAddonController>().refreshProfile();
                                if (context.mounted) Navigator.pop(sheetContext);
                              }
                            },
                          );
                        },
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

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.warning_2, size: 36, color: Colors.redAccent),
            const SizedBox(height: 14),
            AppText(
              "failed_load_plans".tr,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  "retry".tr,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
