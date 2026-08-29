import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:url_launcher/url_launcher_string.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/Rewards/Controllers/RewardsClientController.dart';
import 'package:vclub/Features/Client/Rewards/View/Widgets/ReviewsCard.dart';
import 'GoogleReviewShimmer.dart';

class GoogleReviewTabContent extends StatelessWidget {
  const GoogleReviewTabContent({super.key});

  // void _openReviewLink(String url) {
  //   if (url.isEmpty) return;
  //   launchUrlString(url, mode: LaunchMode.externalApplication);
  // }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GoogleReviewController>();

    return Obx(() {
      if (controller.loading.value && !controller.initialLoaded.value) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 4),
          child: const GoogleReviewShimmer(),
        );
      }

      if (controller.hasError.value && controller.entries.isEmpty) {
        return _ErrorBlock(onRetry: controller.refresh);
      }

      final visibleEntries = controller.entries
          .where((e) => e.review != null)
          .toList();

      if (visibleEntries.isEmpty) {
        return _EmptyBlock();
      }
      final size = MediaQuery.of(context).size;
      return SizedBox(
        height: size.height * 0.52,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(top: 4, bottom: 150),
            itemCount: visibleEntries.length,
            itemBuilder: (context, index) {
              final entry = visibleEntries[index];

              return FadeSlide(
                delayMs: (index * 60).clamp(0, 400),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GoogleReviewRewardCard(
                    companyId: entry.company.companyId,
                    review: entry.review!,
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

class _EmptyBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.star_1,
              size: 40,
              color: AppColors.primary.withOpacity(.5),
            ),
            const SizedBox(height: 14),
            AppText(
              "no_google_review_rewards".tr,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: AppText(
                "no_google_review_rewards_subtitle".tr,
                fontSize: 12,
                color: Colors.grey,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBlock({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.warning_2, size: 36, color: Colors.redAccent),
            const SizedBox(height: 12),
            AppText("failed_load_google_review".tr, fontSize: 13),
            const SizedBox(height: 12),
            InkWell(
              onTap: onRetry,
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
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
