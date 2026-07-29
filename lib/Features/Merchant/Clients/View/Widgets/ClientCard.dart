import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Clients/Models/ClientModel.dart';

class ClientCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback? onTap;

  const ClientCard({super.key, required this.client, this.onTap});

  Color _levelColor() {
    switch (client.level.toLowerCase()) {
      case "bronze":   return const Color(0xFFB87333);
      case "silver":   return const Color(0xFF8F98A3);
      case "gold":     return const Color(0xFFE8B200);
      case "platinum": return const Color(0xFF5B7FFF);
      case "vip":      return const Color(0xFF8E24AA);
      default:         return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor   = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05);
    final mutedColor  = Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5);
    final levelColor  = _levelColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
             color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: .5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// HEADER
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(.10),
                      ),
                      alignment: Alignment.center,
                      child: AppText(
                        client.initials,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Name + meta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            client.fullName,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 3),
                          _MetaRow(icon: Iconsax.sms, label: client.email, color: mutedColor),
                          const SizedBox(height: 2),
                          _MetaRow(icon: Iconsax.call, label: client.phone, color: mutedColor),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: levelColor.withOpacity(.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppText(
                        client.level,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: levelColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(height: 1, color: borderColor),
                const SizedBox(height: 12),

                /// STATS
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _StatItem(icon: Iconsax.coin, value: client.points.toString(), label: "points"),
                      VerticalDivider(width: 1, color: borderColor),
                      _StatItem(icon: Iconsax.scan, value: client.visits.toString(), label: "visits"),
                      VerticalDivider(width: 1, color: borderColor),
                      _StatItem(icon: Iconsax.gift, value: client.rewards.toString(), label: "rewards"),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaRow({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: AppText(
            label,
            fontSize: 11.5,
            color: color,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(height: 4),
          AppText(value, fontWeight: FontWeight.w700, fontSize: 12),
          const SizedBox(height: 1),
          AppText(
            label,
            fontSize: 10.5,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
          ),
        ],
      ),
    );
  }
}