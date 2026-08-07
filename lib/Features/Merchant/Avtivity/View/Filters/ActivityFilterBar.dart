import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Avtivity/Controllers/MerchantActivityController.dart';
import 'package:vclub/Features/Merchant/Avtivity/View/Widgets/ActivityMeta.dart';
import 'ActivityClientSelectSheet.dart';
import 'ActivityDateRangeSheet.dart';
import 'ActivityStaffSelectSheet.dart';
import 'ActivityTypeSelectSheet.dart';

class ActivityFilterBar extends StatelessWidget {
  const ActivityFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantActivityController>();

    return Obx(() {
      final hasFilters = controller.activeFilterCount > 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _FilterChip(
                  icon: Iconsax.category,
                  label: controller.actionFilter.value.isEmpty
                      ? "filter_type".tr
                      : ActivityMeta.of(controller.actionFilter.value).labelKey.tr,
                  active: controller.actionFilter.value.isNotEmpty,
                  onTap: () => showActivityTypeSelectSheet(context),
                ),
                const SizedBox(width: 9),
                _FilterChip(
                  icon: Iconsax.user_tag,
                  label: controller.staffFilter.value?.firstName ?? "filter_staff".tr,
                  active: controller.staffFilter.value != null,
                  onTap: () => showActivityStaffSelectSheet(context),
                ),
                const SizedBox(width: 9),
                _FilterChip(
                  icon: Iconsax.user,
                  label: controller.clientFilter.value?.fullName ?? "filter_client".tr,
                  active: controller.clientFilter.value != null,
                  onTap: () => showActivityClientSelectSheet(context),
                ),
                const SizedBox(width: 9),
                _FilterChip(
                  icon: Iconsax.calendar_1,
                  label: (controller.fromDate.value != null || controller.toDate.value != null)
                      ? "filter_date_active".tr
                      : "filter_date".tr,
                  active: controller.fromDate.value != null || controller.toDate.value != null,
                  onTap: () => showActivityDateRangeSheet(context),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topLeft,
            child: hasFilters
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _ClearFiltersButton(
                      count: controller.activeFilterCount,
                      onTap: controller.clearAllFilters,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: active
            ? LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(.82)])
            : null,
        color: active
            ? null
            : (isDark ? Colors.white.withOpacity(.05) : Colors.white),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: active
              ? Colors.transparent
              : (isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06)),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? .2 : .04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14.5, color: active ? Colors.white : AppColors.primary),
                const SizedBox(width: 7),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 100),
                  child: AppText(
                    label,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                    color: active ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                // const SizedBox(width: 4),
                // Icon(
                //   Iconsax.arrow_circle_down_copy,
                //   size: 12,
                //   color: active ? Colors.white.withOpacity(.85) : Colors.grey.withOpacity(.5),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClearFiltersButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _ClearFiltersButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.redAccent.withOpacity(.09),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.close_circle, size: 14, color: Colors.redAccent),
              const SizedBox(width: 6),
              AppText(
                "${"clear_filters".tr} ($count)",
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}