import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class AuthFooterText extends StatelessWidget {
  final VoidCallback onTap;

  const AuthFooterText({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Text(
          "no_account".tr,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(width: 4),

        GestureDetector(
          onTap: onTap,
          child: Text(
            "create_account".tr,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              decorationColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}