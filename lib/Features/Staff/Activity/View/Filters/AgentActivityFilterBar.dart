import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Avtivity/View/Widgets/ActivityMeta.dart';
import 'package:vclub/Features/Staff/Activity/Controllers/AgentActivityController.dart';
import 'AgentActivityDateRangeSheet.dart';
import 'AgentActivityTypeSelectSheet.dart';

class AgentActivityFilterBar extends StatelessWidget {
  const AgentActivityFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgentActivityController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final hasFilters = controller.activeFilterCount > 0;
      final typeLabel = controller.actionFilter.value.isEmpty
          ? "all_types".tr
          : ActivityMeta.of(controller.actionFilter.value).labelKey.tr;
      final dateLabel = (controller.fromDate.value != null || controller.toDate.value != null)
          ? "filter_date_active".tr
          : "all_dates".tr;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isDark ? const Color(0xFF1C1F26) : Colors.white,
          border: Border.all(color: isDark ? Colors.white.withOpacity(.07) : Colors.black.withOpacity(.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? .25 : .04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.filter, size: 14, color: AppColors.primary),
                const SizedBox(width: 7),
                AppText(
                  "filters_label".tr,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.7),
                ),
                const Spacer(),
                if (hasFilters)
                  InkWell(
                    onTap: controller.clearAllFilters,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.close_circle, size: 13, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          AppText("clear".tr, fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.redAccent),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _FilterSegment(
                    icon: Iconsax.category,
                    label: typeLabel,
                    active: controller.actionFilter.value.isNotEmpty,
                    onTap: () => showAgentActivityTypeSelectSheet(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterSegment(
                    icon: Iconsax.calendar_1,
                    label: dateLabel,
                    active: controller.fromDate.value != null || controller.toDate.value != null,
                    onTap: () => showAgentActivityDateRangeSheet(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _FilterSegment extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterSegment({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: active
          ? AppColors.primary.withOpacity(.1)
          : (isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.03)),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: active ? AppColors.primary.withOpacity(.35) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary.withOpacity(.16) : (isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 13, color: active ? AppColors.primary : Colors.grey.withOpacity(.7)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  label,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis,
                  color: active ? AppColors.primary : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}