import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class SectionUpdateButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const SectionUpdateButton({super.key, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      height: size.height * 0.056,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: loading ? null : onTap,
          child: Center(
            child: loading
                ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 22)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.tick_circle, size: 17, color: Colors.white),
                      const SizedBox(width: 8),
                      AppText("update_section".tr, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}