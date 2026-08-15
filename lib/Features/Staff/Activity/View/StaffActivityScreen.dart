import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Avtivity/View/Widgets/ActivityCard.dart';
import 'package:vclub/Features/Merchant/Avtivity/View/Widgets/ActivityEmptyState.dart';
import 'package:vclub/Features/Merchant/Avtivity/View/Widgets/ActivityErrorState.dart';
import 'package:vclub/Features/Merchant/Avtivity/View/Widgets/ActivityHeader.dart';
import 'package:vclub/Features/Merchant/Avtivity/View/Widgets/ActivityShimmerList.dart';
import 'package:vclub/Features/Staff/Activity/Controllers/AgentActivityController.dart';
import 'Filters/AgentActivityFilterBar.dart';
import 'Widgets/AgentActivityStatsCard.dart';

class StaffActivityScreen extends StatelessWidget {
  const StaffActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AgentActivityController>()) {
      Get.put(AgentActivityController());
    }

    final controller = Get.find<AgentActivityController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * .015),
              const ActivityHeader(),
              SizedBox(height: size.height * .02),
              const FadeSlide(delayMs: 180, child: AgentActivityStatsCard()),
              const SizedBox(height: 16),
              const FadeSlide(delayMs: 220, child: AgentActivityFilterBar()),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.loading.value && !controller.initialLoaded.value) {
                    return const ActivityShimmerList();
                  }

                  if (controller.hasError.value && controller.activities.isEmpty) {
                    return ActivityErrorState(onRetry: () => controller.fetchActivities(reset: true));
                  }

                  if (controller.activities.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: controller.refresh,
                      child: ActivityEmptyState(
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
                        itemCount: controller.activities.length + (controller.loadingMore.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.activities.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 22),
                              child: Center(
                                child: LoadingAnimationWidget.fourRotatingDots(color: AppColors.primary, size: 40),
                              ),
                            );
                          }

                          return ActivityCard(item: controller.activities[index], index: index);
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