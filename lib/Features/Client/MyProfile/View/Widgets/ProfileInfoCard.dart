import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Auth/Models/ClientModel.dart';

/// Plain grouped list of contact details — no internal header, since the
/// section title now lives in the parent screen alongside every other
/// section ("Account", "Contact Information", "My Clubs"), keeping visual
/// rhythm consistent across the whole profile screen.
class ProfileInfoCard extends StatelessWidget {
  final ClientProfileModel client;

  const ProfileInfoCard({super.key, required this.client});

  String _formatBirthday(DateTime? d) {
    if (d == null) return 'not_set'.tr;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? Colors.white.withOpacity(0.045) : Colors.white,
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 20, offset: const Offset(0, 8))],
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.07)) : null,
      ),
      child: Column(
        children: [
          _InfoRow(icon: Iconsax.sms, label: "email".tr, value: client.email.isEmpty ? '-' : client.email, isDark: isDark),
          _hairline(isDark),
          _InfoRow(
            icon: Iconsax.call,
            label: "phone".tr,
            value: (client.phone == null || client.phone!.isEmpty) ? 'not_set'.tr : client.phone!,
            isDark: isDark,
          ),
          _hairline(isDark),
          _InfoRow(
            icon: Iconsax.cake,
            label: "birthday".tr,
            value: _formatBirthday(client.birthday),
            isDark: isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _hairline(bool isDark) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Divider(height: 1, thickness: 1, color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.045)),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, isLast ? 16 : 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.09), borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(label, fontSize: 11, fontWeight: FontWeight.w500, color: theme.textTheme.bodySmall?.color?.withOpacity(0.55)),
                const SizedBox(height: 4),
                AppText(value, fontSize: 12.5, fontWeight: FontWeight.w600, maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}