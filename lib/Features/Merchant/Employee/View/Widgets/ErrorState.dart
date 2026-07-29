import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class EmployeeErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const EmployeeErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.16),
      child: Column(
        children: [
          Container(
            width: w * 0.22,
            height: w * 0.22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEF4444).withOpacity(0.10),
            ),
            child: Icon(
              Iconsax.warning_2,
              color: const Color(0xFFEF4444),
              size: w * 0.10,
            ),
          ),
          SizedBox(height: w * 0.05),
          AppText("something_went_wrong", fontSize: 16, fontWeight: FontWeight.w700),
          SizedBox(height: w * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.1),
            child: Text(
              "error_subtitle".tr,
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
          SizedBox(height: w * 0.06),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  const Icon(Iconsax.refresh, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "retry".tr,
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
      ),
    );
  }
}