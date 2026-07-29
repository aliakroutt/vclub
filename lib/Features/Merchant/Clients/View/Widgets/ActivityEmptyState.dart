import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class ActivityEmptyState extends StatelessWidget {
  const ActivityEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5);
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerColor.withOpacity(.10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        children: [
          Icon(Iconsax.clock, size: 36, color: muted),
          const SizedBox(height: 12),
          AppText('no_activity_yet', fontSize: 14, fontWeight: FontWeight.w600, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          AppText('no_activity_yet_subtitle', fontSize: 12, color: muted, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}