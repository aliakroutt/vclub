import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/PlansController.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/SmsAddonController.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/BillingHeaderCard.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/BillingPortalWebViewScreen.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/BillingStats.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/CancelPlanChoiceSheet.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/CancellationPendingCard.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/ChangePlanCard.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/ChangePlanSheet.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/InvoiceHistoryCard.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/SmsAddonCard.dart';

class Billing extends StatefulWidget {
  const Billing({super.key});

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  @override
  void initState() {
    if (!Get.isRegistered<SmsAddonController>()) {
      Get.put(SmsAddonController());
    }
    if (!Get.isRegistered<PlansController>()) {
      Get.put(PlansController());
    }
    final controller = Get.find<SmsAddonController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshProfile();
      if (!mounted) return;

      final company = MerchantController.to.merchant.value?.company;
      final isFreePlan =
          !(company?.hasSubscription ?? false) ||
          (company?.stripePlan == null || company!.stripePlan!.isEmpty);

      if (isFreePlan) {
        showChangePlanSheet(context);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return KeyboardDismissOnTap(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.01),

                  Align(
                    alignment: isRTL
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: FadeSlide(
                      delayMs: 200,
                      child: AppText(
                        "billing".tr,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.01),

                  Align(
                    alignment: isRTL
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: FadeSlide(
                      delayMs: 250,
                      child: AppText(
                        'billing_description'.tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  Obx(() {
                    final company =
                        MerchantController.to.merchant.value?.company;

                    return FadeSlide(
                      delayMs: 250,
                      child: CompanyHeaderCard(
                        company: company,
                        onManageSubscription: () async {
                          final url = await Get.find<SmsAddonController>()
                              .fetchBillingPortalUrl();
                          if (url == null) return;
                          if (!context.mounted) return;

                          Get.to(
                            () => BillingPortalWebViewScreen(portalUrl: url),
                          );
                        },
                        onCancelSubscription: () async {
                          showCancelPlanChoiceSheet(context);
                        },
                      ),
                    );
                  }),

                  Obx(() {
                    final company =
                        MerchantController.to.merchant.value?.company;
                    final cancelScheduled = company?.cancelAtPeriodEnd ?? false;

                    if (!cancelScheduled) return const SizedBox.shrink();

                    return Column(
                      children: [
                        SizedBox(height: size.height * 0.02),
                        FadeSlide(
                          delayMs: 270,
                          child: CancellationPendingCard(
                            subscriptionEndsAt: company?.subscriptionEndsAt,
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: size.height * 0.02),
                  Obx(() {
                    final company =
                        MerchantController.to.merchant.value?.company;
                    final isFreePlan =
                        !(company?.hasSubscription ?? false) ||
                        (company?.stripePlan == null ||
                            company!.stripePlan!.isEmpty);

                    return FadeSlide(
                      delayMs: 280,
                      child: ChangePlanCard(isFreePlan: isFreePlan),
                    );
                  }),

                  SizedBox(height: size.height * 0.02),
                  const FadeSlide(delayMs: 290, child: SmsAddonCard()),

                  SizedBox(height: size.height * 0.02),
                  FadeSlide(delayMs: 320, child: BillingStatsRow()),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(delayMs: 350, child: InvoiceHistoryCard()),

                  SizedBox(height: size.height * 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
