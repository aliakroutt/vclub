import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class TransactionItemCard extends StatelessWidget {
  final String company;
  final String description;
  final int points;
  final String date;

  const TransactionItemCard({
    super.key,
    required this.company,
    required this.description,
    required this.points,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';

    final size = MediaQuery.of(context).size;

    final isPositive = points >= 0;

    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.9),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          // LEFT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: isRTL
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                AppText(
                  company,
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 4),
                AppText(
                  description,
                  fontSize: size.width * 0.03,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.7),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // RIGHT SIDE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // POINTS
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${isPositive ? '+' : ''}$points",
                  style: TextStyle(
                    fontSize: size.width * 0.032,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // DATE
              Text(
                date,
                style: TextStyle(
                  fontSize: size.width * 0.028,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}