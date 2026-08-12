import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/SmsAddonController.dart';

Future<void> showCancelPlanChoiceSheet(BuildContext context) {
  final controller = Get.find<SmsAddonController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Iconsax.close_circle, color: Colors.redAccent, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText("cancel_plan_sheet_title".tr, fontSize: 16.5, fontWeight: FontWeight.w800),
                        const SizedBox(height: 3),
                        AppText(
                          "cancel_plan_sheet_subtitle".tr,
                          fontSize: 12.5,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Obx(() {
                final loading = controller.isCanceling.value;

                return Column(
                  children: [
                    _CancelOption(
                      icon: Iconsax.calendar_tick,
                      color: AppColors.primary,
                      title: "cancel_period_end_title".tr,
                      subtitle: "cancel_period_end_subtitle".tr,
                      // badge: "recommended".tr,
                      enabled: !loading,
                      onTap: () async {
                        final success = await controller.cancelSubscription(immediate: false);
                        if (success && sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                    ),
                    const SizedBox(height: 12),
                    _CancelOption(
                      icon: Iconsax.flash_1,
                      color: Colors.redAccent,
                      title: "cancel_immediate_title".tr,
                      subtitle: "cancel_immediate_subtitle".tr,
                      enabled: !loading,
                      onTap: () async {
                        final success = await controller.cancelSubscription(immediate: true);
                        if (success && sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                    ),
                    if (loading) ...[
                      const SizedBox(height: 18),
                      Center(child: LoadingAnimationWidget.fourRotatingDots(color: AppColors.primary, size: 28)),
                    ],
                  ],
                );
              }),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1)),
                  ),
                  child: AppText("keep_my_plan".tr, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CancelOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? badge;
  final bool enabled;
  final VoidCallback onTap;

  const _CancelOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.025),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(.18), color.withOpacity(.08)],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppText(title, fontSize: 13.5, fontWeight: FontWeight.w800),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(.12),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: AppText(badge!, fontSize: 9.5, fontWeight: FontWeight.w800, color: color),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      subtitle,
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Iconsax.arrow_circle_right_copy, size: 16, color: color.withOpacity(.6)),
            ],
          ),
        ),
      ),
    );
  }
}