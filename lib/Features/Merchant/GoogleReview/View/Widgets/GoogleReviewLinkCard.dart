import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/GoogleReview/Controllers/MerchantGoogleReviewController.dart';
import 'ShareLinkSheet.dart';

class GoogleReviewLinkCard extends StatelessWidget {
  const GoogleReviewLinkCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantGoogleReviewController>();
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * 0.038),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: size.width * 0.09,
                height: size.width * 0.09,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color(0xFF6C5CE7).withOpacity(0.1)),
                child: const Icon(Iconsax.link_21, color: Color(0xFF6C5CE7), size: 17),
              ),
              SizedBox(width: size.width * 0.025),
              AppText("google_review_link".tr, fontSize: size.width * 0.036, fontWeight: FontWeight.w600),
            ],
          ),

          SizedBox(height: size.height * 0.012),
          AppText("google_review_link_description".tr, fontSize: size.width * 0.028, color: Colors.grey),
          SizedBox(height: size.height * 0.01),

          Obx(() {
            final link = controller.reviewLink.value;
            final hasLink = link.isNotEmpty;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: size.height * 0.014),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.global, size: 14, color: Colors.grey.withOpacity(.7)),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: AppText(
                      hasLink ? link : "no_review_link_set".tr,
                      fontSize: size.width * 0.030,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                      color: hasLink ? null : Colors.grey.withOpacity(.6),
                    ),
                  ),
                ],
              ),
            );
          }),

          SizedBox(height: size.height * 0.014),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: Material(
              color: const Color(0xFF6C5CE7),
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () => showShareLinkSheet(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.share, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    AppText("manage_share_link".tr, fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
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