// ignore_for_file: unused_element, unused_local_variable, use_key_in_widget_constructors



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/Dashboard/Models/LoyaltyCardModel.dart';

class LoyaltyInfoColumn extends StatelessWidget {
  final LoyaltyCardModel card;

  const LoyaltyInfoColumn({required this.card});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
      FadeSlide(
              delayMs: 400,
              child: _MiniInfoTile(
          icon: Iconsax.star_1,
          title: "points".tr,
          value: "${card.points}/${card.targetPoints}",
          color: AppColors.primary,
          isDark: isDark,
        )),
        const SizedBox(height: 10),

      FadeSlide(
              delayMs: 500,
              child:  _MiniInfoTile(
          icon: Iconsax.repeat,
          title: "transactions".tr,
          value: "${card.transactions}",
          color:AppColors.primary,
          isDark: isDark,
        )),
        const SizedBox(height: 10),

      FadeSlide(
              delayMs: 600,
              child: _MiniInfoTile(
          icon: Iconsax.building,
          title: "company".tr,
          value: card.name,
          color: AppColors.primary,
          isDark: isDark,
        )),
        const SizedBox(height: 10),

       FadeSlide(
              delayMs: 700,
              child: _MiniInfoTile(
          icon: Iconsax.medal_star,
          title: "type".tr,
          value: card.type,
          color: AppColors.primary,
          isDark: isDark,
        )),
      ],
    );
  }
}

class _MiniInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isDark;

  const _MiniInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.9),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}