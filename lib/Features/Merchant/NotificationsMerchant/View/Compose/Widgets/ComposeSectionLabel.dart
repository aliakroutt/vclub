import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class ComposeSectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;

  const ComposeSectionLabel({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 7),
        AppText(label, fontSize: 13, fontWeight: FontWeight.w700),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}