import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/FortuneWheel/Controllers/FortuneWheelController.dart';
import 'package:vclub/Features/Client/FortuneWheel/Models/FortuneWheelModels.dart';

class WheelHistoryList extends StatelessWidget {
  const WheelHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FortuneWheelController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final items = controller.history; // full list, no company filter

      if (items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: AppText("no_wheel_history".tr, fontSize: 12.5, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5)),
          ),
        );
      }

      return Column(
        children: items.map((item) {
          final color = item.isWin ? const Color(0xFF00C896) : Colors.grey;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1F26) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
            ),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(11)),
                  child: Icon(item.type.icon, size: 17, color: color),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(item.label, fontSize: 13, fontWeight: FontWeight.w700),
                      const SizedBox(height: 2),
                      AppText(
                        DateFormat('d MMM yyyy • HH:mm').format(item.createdAt),
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                      ),
                    ],
                  ),
                ),
                if (item.code != null && item.code!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
                    child: AppText(item.code!, fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
                  ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}