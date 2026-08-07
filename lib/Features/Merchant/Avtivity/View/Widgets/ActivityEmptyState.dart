import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class ActivityEmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback? onClearFilters;

  const ActivityEmptyState({super.key, this.hasFilters = false, this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
         padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(.16),
                      AppColors.primary.withOpacity(.04),
                    ],
                  ),
                ),
                child: Icon(Iconsax.activity, size: 40, color: AppColors.primary.withOpacity(.7)),
              ),
              const SizedBox(height: 24),
              AppText(
                "no_activity_found".tr,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              AppText(
                hasFilters ? "no_activity_filtered_subtitle".tr : "no_activity_subtitle".tr,
                fontSize: 13.5,
                textAlign: TextAlign.center,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
              ),
              if (hasFilters && onClearFilters != null) ...[
                const SizedBox(height: 20),
                InkWell(
                  onTap: onClearFilters,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AppText(
                      "clear_filters".tr,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}