import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';


class NextButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final bool isEnabled;
  final double? width;

  const NextButton({
    super.key,
    required this.text,
    this.onTap,
    this.isEnabled = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isEnabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(50),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: width,
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02,
            ),
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.8),
              borderRadius: BorderRadius.circular(50),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text,
                  color: isEnabled ? Colors.white : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: size.width * 0.038,
                ),

                SizedBox(width: size.width * 0.02),

                Icon(
                 Get.locale?.languageCode == 'ar' ? Iconsax.arrow_left_copy  :  Iconsax.arrow_right_1_copy,
                  color: Colors.white,
                  size: size.width * 0.045,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}