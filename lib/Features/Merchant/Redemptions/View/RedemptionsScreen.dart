import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Redemptions/Controllers/MerchantRedemptionsController.dart';
import 'Widgets/RedemptionCard.dart';
import 'Widgets/RedemptionEmptyState.dart';
import 'Widgets/RedemptionErrorState.dart';
import 'Widgets/RedemptionHeader.dart';
import 'Widgets/RedemptionShimmerList.dart';
import 'Widgets/RedemptionStatsCard.dart';
import 'Widgets/Filters/RedemptionFilterBar.dart';

class RedemptionsScreen extends StatefulWidget {
  const RedemptionsScreen({super.key});

  @override
  State<RedemptionsScreen> createState() => _RedemptionsScreenState();
}

class _RedemptionsScreenState extends State<RedemptionsScreen> {
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MerchantRedemptionsController>()) {
      Get.put(MerchantRedemptionsController());
    }

    final controller = Get.find<MerchantRedemptionsController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * .015),
              const RedemptionHeader(),
              SizedBox(height: size.height * .02),
              const FadeSlide(delayMs: 180, child: RedemptionStatsCard()),
              const SizedBox(height: 16),
              const FadeSlide(delayMs: 220, child: RedemptionFilterBar()),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.loading.value && !controller.initialLoaded.value) {
                    return const RedemptionShimmerList();
                  }

                  if (controller.hasError.value && controller.redemptions.isEmpty) {
                    return RedemptionErrorState(onRetry: () => controller.fetchRedemptions(reset: true));
                  }

                  if (controller.redemptions.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: controller.refresh,
                      child: RedemptionEmptyState(
                        hasFilters: controller.activeFilterCount > 0,
                        onClearFilters: controller.clearAllFilters,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: controller.refresh,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scroll) {
                        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
                          controller.loadMore();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(bottom: 120, top: 4),
                        itemCount: controller.redemptions.length + (controller.loadingMore.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.redemptions.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 22),
                              child: Center(
                                child: LoadingAnimationWidget.fourRotatingDots(color: AppColors.primary, size: 40),
                              ),
                            );
                          }

                          return RedemptionCard(item: controller.redemptions[index], index: index);
                        },
                      ),
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