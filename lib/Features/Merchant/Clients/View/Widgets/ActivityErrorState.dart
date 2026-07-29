import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class ActivityErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const ActivityErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          Icon(Iconsax.warning_2_copy, size: 44, color: muted),
          const SizedBox(height: 14),
          AppText('something_went_wrong', fontSize: 14, fontWeight: FontWeight.w600, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          AppText('client_details_error_subtitle', fontSize: 12, color: muted, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onRetry,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: AppText('retry', color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}