import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Audit/Controllers/MerchantAuditController.dart';
import 'Widgets/AuditCard.dart';
import 'Widgets/AuditEmptyState.dart';
import 'Widgets/AuditErrorState.dart';
import 'Widgets/AuditHeader.dart';
import 'Widgets/AuditShimmerList.dart';
import 'Widgets/AuditStatsCard.dart';
import 'Widgets/Filters/AuditFilterBar.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MerchantAuditController>()) {
      Get.put(MerchantAuditController());
    }

    final controller = Get.find<MerchantAuditController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * .015),
              const AuditHeader(),
              SizedBox(height: size.height * .02),
              const FadeSlide(delayMs: 180, child: AuditStatsCard()),
              const SizedBox(height: 16),
              const FadeSlide(delayMs: 220, child: AuditFilterBar()),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.loading.value && !controller.initialLoaded.value) {
                    return const AuditShimmerList();
                  }

                  if (controller.hasError.value && controller.logs.isEmpty) {
                    return AuditErrorState(onRetry: () => controller.fetchLogs(reset: true));
                  }

                  if (controller.logs.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: controller.refresh,
                      child: AuditEmptyState(
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
                        itemCount: controller.logs.length + (controller.loadingMore.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.logs.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 22),
                              child: Center(
                                child: LoadingAnimationWidget.fourRotatingDots(color: AppColors.primary, size: 40),
                              ),
                            );
                          }

                          return AuditCard(item: controller.logs[index], index: index);
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