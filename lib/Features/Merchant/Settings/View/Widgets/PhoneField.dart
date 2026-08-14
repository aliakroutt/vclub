import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const PhoneField({super.key, required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: size.width * .031,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65),
        ),
        SizedBox(height: size.height * .008),
        Container(
          height: size.height * .062,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
            border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
          ),
          child: Row(
            children: [
              SizedBox(width: size.width * .035),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.call, size: 14, color: AppColors.primary),
                  ],
                ),
              ),
              SizedBox(width: size.width * .03),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))],
                  style: TextStyle(fontSize: size.width * .034, fontWeight: FontWeight.w600, letterSpacing: .3),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: "+216 99 999 999",
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(.5), fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(width: size.width * .035),
            ],
          ),
        ),
      ],
    );
  }
}