import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class ForgetPasswordText extends StatelessWidget {
  final VoidCallback onTap;

  const ForgetPasswordText({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Align(
      alignment: isArabic
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          "forget_password".tr,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            decorationColor: AppColors.primary,
          ),
        ),
      ),
    );
  }
}