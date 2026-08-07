import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/MerchantNotificationsController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/SentNotificationCard.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/SentNotificationsEmptyState.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/SentNotificationsErrorState.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/SentNotificationsShimmerList.dart';

class SentNotificationsTab extends StatelessWidget {
  const SentNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantNotificationsController>();

    return Obx(() {
      if (controller.loading.value && !controller.initialLoaded.value) {
        return const SentNotificationsShimmerList();
      }

      if (controller.error.value.isNotEmpty && controller.notifications.isEmpty) {
        return SentNotificationsErrorState(
          message: controller.error.value,
          onRetry: () => controller.fetchNotifications(refresh: true),
        );
      }

      if (controller.notifications.isEmpty) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshNotifications,
          child: SentNotificationsEmptyState(
            onCompose: () => DefaultTabController.of(context).animateTo(0),
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refreshNotifications,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
              controller.loadMore();
            }
            return false;
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.only(bottom: 120, top: 2),
            itemCount:
                controller.notifications.length + (controller.loadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                );
              }

              return SentNotificationCard(
                notification: controller.notifications[index],
                index: index,
              );
            },
          ),
        ),
      );
    });
  }
}