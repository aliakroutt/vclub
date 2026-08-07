import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/ComposeNotificationController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Models/SendNotificationDto.dart';
import 'ComposeSectionLabel.dart';

class _RecipientOption {
  final NotificationRecipientType type;
  final IconData icon;
  final String labelKey;

  const _RecipientOption(this.type, this.icon, this.labelKey);
}

const List<_RecipientOption> _options = [
  _RecipientOption(NotificationRecipientType.all, Iconsax.people, "all_members"),
  _RecipientOption(NotificationRecipientType.vip, Iconsax.crown_1, "vip_members"),
  _RecipientOption(NotificationRecipientType.inactive, Iconsax.timer_pause, "inactive_members"),
  _RecipientOption(NotificationRecipientType.program, Iconsax.medal_star, "program_label"),
  _RecipientOption(NotificationRecipientType.client, Iconsax.user, "client_label"),
];

class RecipientTypeSelector extends StatelessWidget {
  const RecipientTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComposeNotificationController>();

    return Obx(() {
      final hasError = controller.recipientError.value.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ComposeSectionLabel(icon: Iconsax.send_2, label: "", ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppText("recipients_label".tr, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _options.map((option) {
              final selected = controller.recipientType.value == option.type;

              return _RecipientChip(
                icon: option.icon,
                label: option.labelKey.tr,
                selected: selected,
                onTap: () => controller.selectRecipient(option.type),
              );
            }).toList(),
          ),
          if (hasError) ...[
            const SizedBox(height: 8),
            AppText(
              controller.recipientError.value,
              fontSize: 11.5,
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ],
        ],
      );
    });
  }
}

class _RecipientChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RecipientChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary
            : (isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.035)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? AppColors.primary
              : (isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06)),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: selected ? Colors.white : AppColors.primary),
                const SizedBox(width: 6),
                AppText(
                  label,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}