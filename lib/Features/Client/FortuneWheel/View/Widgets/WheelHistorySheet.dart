import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'WheelHistoryList.dart';

Future<void> showWheelHistorySheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: .75,
        minChildSize: .4,
        maxChildSize: .92,
        expand: false,
        builder: (context, scrollController) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1F26) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(.12), borderRadius: BorderRadius.circular(10)),
                          child: Icon(Iconsax.clock, size: 16, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        AppText("wheel_history_title".tr, fontSize: 16, fontWeight: FontWeight.w800),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: const WheelHistoryList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}