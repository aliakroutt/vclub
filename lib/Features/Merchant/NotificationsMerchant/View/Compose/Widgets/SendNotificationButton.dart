import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/ComposeNotificationController.dart';

class SendNotificationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SendNotificationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComposeNotificationController>();

    return Obx(() {
      final sending = controller.sending.value;

      return SizedBox(
        width: double.infinity,
        height: 52,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: sending ? null : onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(.35),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: sending
                    ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 28)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.send_2, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          AppText(
                            "send_notification_button".tr,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
    });
  }
}