import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'WheelHistorySheet.dart';

class HistoryIconButton extends StatelessWidget {
  const HistoryIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => showWheelHistorySheet(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F26) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? Colors.white.withOpacity(.07) : Colors.black.withOpacity(.06)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? .2 : .04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primary.withOpacity(.75)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Icon(Iconsax.clock, color: Colors.white, size: 19),
              ),
              const SizedBox(height: 10),
              AppText("wheel_history_title".tr, fontSize: 13.5, fontWeight: FontWeight.w800),
              const SizedBox(height: 3),
              AppText(
                "history_button_subtitle".tr,
                fontSize: 11,
                textAlign: TextAlign.center,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}