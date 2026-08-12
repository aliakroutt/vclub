import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/GoogleReview/Controllers/MerchantGoogleReviewController.dart';
import 'package:vclub/Features/Merchant/GoogleReview/View/Widgets/GoogleReviewLinkCard.dart';
import 'package:vclub/Features/Merchant/GoogleReview/View/Widgets/RewardAfterReviewCard.dart';
import 'package:vclub/Features/Merchant/GoogleReview/View/Widgets/ReviewStatsCards.dart';

class MerchantGoogleReview extends StatefulWidget {
  const MerchantGoogleReview({super.key});

  @override
  State<MerchantGoogleReview> createState() => _MerchantGoogleReviewState();
}

class _MerchantGoogleReviewState extends State<MerchantGoogleReview> {
   final controller = !Get.isRegistered<MerchantGoogleReviewController>() ? Get.put(MerchantGoogleReviewController())  :  Get.find<MerchantGoogleReviewController>();
  @override
  void initState() {

    super.initState();
    controller.fetchAll();
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
                    alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                    child: FadeSlide(
                      delayMs: 200,
                      child: AppText("google_reviews".tr, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ),

                  SizedBox(height: size.height * 0.01),

                  Align(
                    alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                    child: FadeSlide(
                      delayMs: 250,
                      child: AppText(
                        'google_reviews_description'.tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  Obx(() {
                    if (controller.hasError.value && !controller.initialLoaded.value) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: size.height * .06),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Iconsax.warning_2, size: 36, color: Colors.redAccent),
                              const SizedBox(height: 12),
                              AppText("failed_load_google_review".tr, fontSize: 13, textAlign: TextAlign.center),
                              const SizedBox(height: 14),
                              InkWell(
                                onTap: controller.refresh,
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

                    return Column(
                      children: [
                        const GoogleReviewsStatsColumn(),
                        SizedBox(height: size.height * 0.02),
                        FadeSlide(delayMs: 400, child: const GoogleReviewLinkCard()),
                        SizedBox(height: size.height * 0.02),
                        FadeSlide(delayMs: 450, child: const RewardAfterReviewCard()),
                      ],
                    );
                  }),

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