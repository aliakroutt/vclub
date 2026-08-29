import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/Rewards/Controllers/RewardsClientController.dart';
import 'package:vclub/Features/Client/Rewards/View/Widgets/GoogleReviewCard.dart';
import 'package:vclub/Features/Client/Rewards/View/Widgets/GoogleReviewShimmer.dart';

class GoogleReviewListScreen extends StatelessWidget {
  const GoogleReviewListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GoogleReviewController>()) {
      Get.put(GoogleReviewController());
    }

    final controller = Get.find<GoogleReviewController>();
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * .015),

              Align(
                alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                child: FadeSlide(delayMs: 150, child: AppText("google_review_rewards_title".tr, fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                child: FadeSlide(
                  delayMs: 200,
                  child: AppText(
                    "google_review_rewards_subtitle".tr,
                    fontSize: 12.5,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65),
                  ),
                ),
              ),

              SizedBox(height: size.height * .025),

              Expanded(
                child: Obx(() {
                  if (controller.loading.value && !controller.initialLoaded.value) {
                    return SingleChildScrollView(child: const GoogleReviewShimmer());
                  }

                  if (controller.hasError.value && controller.entries.isEmpty) {
                    return _ErrorBlock(onRetry: controller.refresh);
                  }

                  final visibleEntries = controller.entries.where((e) => e.review != null).toList();

                  if (visibleEntries.isEmpty) {
                    return _EmptyBlock();
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: controller.refresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(bottom: 40),
                      itemCount: visibleEntries.length,
                      itemBuilder: (context, index) {
                        return FadeSlide(
                          delayMs: 100 + (index * 60).clamp(0, 400),
                          child: GoogleReviewCard(entry: visibleEntries[index]),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.star_1, size: 40, color: AppColors.primary.withOpacity(.5)),
          const SizedBox(height: 14),
          AppText("no_google_review_rewards".tr, fontSize: 14, fontWeight: FontWeight.w700),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: AppText("no_google_review_rewards_subtitle".tr, fontSize: 12, color: Colors.grey, textAlign: TextAlign.center),
          ),
        ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.warning_2, size: 36, color: Colors.redAccent),
          const SizedBox(height: 12),
          AppText("failed_load_google_review".tr, fontSize: 13),
          const SizedBox(height: 12),
          InkWell(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
              child: AppText("retry".tr, color: Colors.redAccent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}