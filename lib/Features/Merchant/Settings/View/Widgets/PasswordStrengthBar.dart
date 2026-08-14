import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Settings/Utils/PasswordStrength.dart';

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final level = PasswordStrength.level(password);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (level == PasswordStrengthLevel.empty) return const SizedBox.shrink();

    final (color, label, segments) = switch (level) {
      PasswordStrengthLevel.weak => (Colors.redAccent, "password_strength_weak".tr, 1),
      PasswordStrengthLevel.medium => (Colors.orangeAccent, "password_strength_medium".tr, 2),
      PasswordStrengthLevel.strong => (const Color(0xFF00C896), "password_strength_strong".tr, 3),
      PasswordStrengthLevel.empty => (Colors.grey, "", 0),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(3, (i) {
              final active = i < segments;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: active ? color : (isDark ? Colors.white.withOpacity(.1) : Colors.black.withOpacity(.08)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          AppText(label, fontSize: 11, fontWeight: FontWeight.w700, color: color),
        ],
      ),
    );
  }
}