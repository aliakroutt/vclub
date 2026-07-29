import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class EmployeeEmptyState extends StatelessWidget {
  final bool isSearching;
  final VoidCallback? onAdd;

  const EmployeeEmptyState({
    super.key,
    required this.isSearching,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.of(context).size.width;

    final titleKey = isSearching ? "no_results_found" : "no_employees_found";
    final subtitleKey = isSearching ? "no_results_subtitle" : "no_employees_subtitle";

    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.16),
      child: Column(
        children: [
          Container(
            width: w * 0.24,
            height: w * 0.24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.08),
            ),
            child: Icon(
              isSearching ? Iconsax.search_status : Iconsax.people,
              color: AppColors.primary.withOpacity(0.55),
              size: w * 0.10,
            ),
          ),
          SizedBox(height: w * 0.05),
          AppText(titleKey, fontSize: 16, fontWeight: FontWeight.w700),
          SizedBox(height: w * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.14),
            child: Text(
              subtitleKey.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: isDark
                    ? Colors.white.withOpacity(0.45)
                    : Colors.black.withOpacity(0.40),
              ),
            ),
          ),
          if (!isSearching && onAdd != null) ...[
            SizedBox(height: w * 0.06),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.add_copy, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "add_employee".tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}