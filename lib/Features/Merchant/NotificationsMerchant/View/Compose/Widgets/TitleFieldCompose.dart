import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/ComposeNotificationController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/Compose/Widgets/ComposeSectionLabel.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/Compose/Widgets/ComposeStyles.dart';


class TitleFieldCompose extends StatelessWidget {
  const TitleFieldCompose({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComposeNotificationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final hasError = controller.titleError.value.isNotEmpty;
      final nearLimit = controller.titleLength.value >
          (ComposeNotificationController.titleMax * .85);

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: composePanelDecoration(context).copyWith(
          border: Border.all(
            color: hasError
                ? Colors.redAccent.withOpacity(.6)
                : (isDark
                    ? Colors.white.withOpacity(.06)
                    : Colors.black.withOpacity(.05)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ComposeSectionLabel(
              icon: Iconsax.text,
              label: "notification_title_label".tr,
              trailing: AppText(
                "${controller.titleLength.value}/${ComposeNotificationController.titleMax}",
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: nearLimit
                    ? Colors.orangeAccent
                    : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.45),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.titleController,
              focusNode: controller.titleFocus,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                LengthLimitingTextInputFormatter(ComposeNotificationController.titleMax),
              ],
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: "title_placeholder".tr,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.4),
                ),
              ),
              onSubmitted: (_) => controller.bodyFocus.requestFocus(),
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              AppText(
                controller.titleError.value,
                fontSize: 11.5,
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ],
          ],
        ),
      );
    });
  }
}