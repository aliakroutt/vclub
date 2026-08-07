import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/ComposeNotificationController.dart';
import 'ComposeSectionLabel.dart';
import 'ComposeStyles.dart';
import 'EmojiPickerSheet.dart';

class MessageFieldCompose extends StatelessWidget {
  const MessageFieldCompose({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComposeNotificationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final hasError = controller.bodyError.value.isNotEmpty;
      final nearLimit = controller.bodyLength.value >
          (ComposeNotificationController.bodyMax * .85);

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
              icon: Iconsax.message_text,
              label: "notification_message_label".tr,
              trailing: AppText(
                "${controller.bodyLength.value}/${ComposeNotificationController.bodyMax}",
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: nearLimit
                    ? Colors.orangeAccent
                    : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.45),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.bodyController,
              focusNode: controller.bodyFocus,
              maxLines: 5,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              inputFormatters: [
                LengthLimitingTextInputFormatter(ComposeNotificationController.bodyMax),
              ],
              style: const TextStyle(fontSize: 14, height: 1.4),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: "message_placeholder".tr,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.4),
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              AppText(
                controller.bodyError.value,
                fontSize: 11.5,
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ],
            const SizedBox(height: 10),
            Divider(
              height: 1,
              color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _ToolbarButton(
                  icon: Iconsax.text_bold,
                  tooltip: "bold".tr,
                  onTap: () => controller.wrapSelection("*"),
                ),
                const SizedBox(width: 6),
                _ToolbarButton(
                  icon: Iconsax.text_italic,
                  tooltip: "italic".tr,
                  onTap: () => controller.wrapSelection("_"),
                ),
                const SizedBox(width: 6),
                _ToolbarButton(
                  icon: Iconsax.emoji_happy,
                  tooltip: "emoji".tr,
                  onTap: () => showEmojiPickerSheet(context, controller.insertEmoji),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark ? Colors.white.withOpacity(.06) : AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}