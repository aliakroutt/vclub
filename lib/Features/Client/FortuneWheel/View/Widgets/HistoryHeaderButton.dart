import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'WheelHistorySheet.dart';

class HistoryHeaderButton extends StatelessWidget {
  const HistoryHeaderButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: AppColors.primary.withOpacity(isDark ? .16 : .1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => showWheelHistorySheet(context),
        child: Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(.25)),
          ),
          child: Icon(Iconsax.clock, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}