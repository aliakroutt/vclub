import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/ComposeNotificationController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/MerchantNotificationsController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/Compose/Widgets/MessageFieldCompose.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/Compose/Widgets/RecipientCard.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/Compose/Widgets/SendNotificationButton.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/Compose/Widgets/SendResultSheet.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/Compose/Widgets/TitleFieldCompose.dart';


class ComposeNotificationTab extends StatelessWidget {
  const ComposeNotificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ComposeNotificationController>()) {
      Get.put(ComposeNotificationController());
    }

    final controller = Get.find<ComposeNotificationController>();
   final notcontroller = Get.find<MerchantNotificationsController>();
    Future<void> handleSend() async {
      final result = await controller.submit();

      if (!context.mounted) return;

      await showSendResultSheet(
        context,
        success: result.success,
        message: result.message,
        onPrimary: () {
          if (result.success) {
            controller.resetForm(); 
            notcontroller.refreshNotifications();

          } 
        },
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FadeSlide(delayMs: 150, child: TitleFieldCompose()),
          const SizedBox(height: 14),
          const FadeSlide(delayMs: 200, child: MessageFieldCompose()),
          const SizedBox(height: 14),
          const FadeSlide(delayMs: 250, child: RecipientCard()),
          const SizedBox(height: 26),
          FadeSlide(
            delayMs: 300,
            child: SendNotificationButton(onPressed: handleSend),
          ),
           const SizedBox(height: 120),
        ],
      ),
    );
  }
}