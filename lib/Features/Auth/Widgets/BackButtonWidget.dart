import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final double? width;

  const BackButtonWidget({
    super.key,
    required this.text,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isArabic = Get.locale?.languageCode == 'ar';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: width,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isArabic
                    ? Iconsax.arrow_right_1_copy
                    : Iconsax.arrow_left_copy,
                color: Colors.black,
                size: size.width * 0.045,
              ),

              SizedBox(width: size.width * 0.02),

              AppText(
                text,
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: size.width * 0.038,
              ),
            ],
          ),
        ),
      ),
    );
  }
}