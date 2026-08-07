import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/ComposeNotificationController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Models/SendNotificationDto.dart';
import 'ClientSelectSheet.dart';
import 'ComposeStyles.dart';
import 'ProgramSelectSheet.dart';
import 'SelectedEntityCard.dart';

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

class RecipientCard extends StatelessWidget {
  const RecipientCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ComposeNotificationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void handleChipTap(NotificationRecipientType type) {
      final alreadySelected = controller.recipientType.value == type;
      controller.selectRecipient(type);

      if (type == NotificationRecipientType.program &&
          (!alreadySelected || controller.selectedProgram.value == null)) {
        Future.delayed(const Duration(milliseconds: 80), () => showProgramSelectSheet(context));
      }
      if (type == NotificationRecipientType.client &&
          (!alreadySelected || controller.selectedClient.value == null)) {
        Future.delayed(const Duration(milliseconds: 80), () => showClientSelectSheet(context));
      }
    }

    return Obx(() {
      final hasError = controller.recipientError.value.isNotEmpty;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: composePanelDecoration(context).copyWith(
          border: Border.all(
            color: hasError
                ? Colors.redAccent.withOpacity(.6)
                : (isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(Iconsax.send_2, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText("recipients_label".tr, fontSize: 13.5, fontWeight: FontWeight.w800),
                      AppText(
                        "recipients_subtitle".tr,
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _options.map((option) {
                final selected = controller.recipientType.value == option.type;

                return _RecipientChip(
                  icon: option.icon,
                  label: option.labelKey.tr,
                  selected: selected,
                  onTap: () => handleChipTap(option.type),
                );
              }).toList(),
            ),
            if (controller.recipientType.value == NotificationRecipientType.program)
              controller.selectedProgram.value != null
                  ? SelectedEntityCard(
                      icon: Iconsax.medal_star,
                      title: controller.selectedProgram.value!.name,
                      subtitle: controller.selectedProgram.value!.mode,
                      onChange: () => showProgramSelectSheet(context),
                    )
                  : _ChoosePrompt(
                      icon: Iconsax.medal_star,
                      label: "choose_program_prompt".tr,
                      onTap: () => showProgramSelectSheet(context),
                    ),
            if (controller.recipientType.value == NotificationRecipientType.client)
              controller.selectedClient.value != null
                  ? SelectedEntityCard(
                      icon: Iconsax.user,
                      title: controller.selectedClient.value!.fullName,
                      subtitle: controller.selectedClient.value!.email.isNotEmpty
                          ? controller.selectedClient.value!.email
                          : controller.selectedClient.value!.phone,
                      onChange: () => showClientSelectSheet(context),
                    )
                  : _ChoosePrompt(
                      icon: Iconsax.user,
                      label: "choose_client_prompt".tr,
                      onTap: () => showClientSelectSheet(context),
                    ),
            if (hasError) ...[
              const SizedBox(height: 10),
              AppText(
                controller.recipientError.value,
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
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? null
            : (isDark ? Colors.white.withOpacity(.045) : Colors.black.withOpacity(.032)),
        gradient: selected
            ? LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(.82)])
            : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? Colors.transparent
              : (isDark ? Colors.white.withOpacity(.07) : Colors.black.withOpacity(.05)),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.32),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
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
                Icon(icon, size: 14.5, color: selected ? Colors.white : AppColors.primary),
                const SizedBox(width: 6),
                AppText(
                  label,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoosePrompt extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ChoosePrompt({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: DottedBorderBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  AppText(label, fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Icon(Iconsax.arrow_circle_right_copy, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lightweight dashed-border container (no extra package).
class DottedBorderBox extends StatelessWidget {
  final Widget child;

  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: AppColors.primary.withOpacity(.35)),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(14),
    );

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      const dashWidth = 5.0;
      const dashGap = 4.0;

      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}