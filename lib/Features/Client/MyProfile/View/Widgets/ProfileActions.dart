import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

/// Grouped "Account" actions card — Edit Information, Change Password,
/// Change Photo — styled like the settings groups in Revolut / Wise /
/// Instagram's account screen: one rounded container, flat rows, hairline
/// dividers, a soft press-scale on tap instead of a ripple-only response.
class ProfileActionsCard extends StatelessWidget {
  final VoidCallback? onEditInfo;
  final VoidCallback? onChangePassword;
  final VoidCallback? onChangePhoto;

  const ProfileActionsCard({
    super.key,
    this.onEditInfo,
    this.onChangePassword,
    this.onChangePhoto,
  });

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
          _ActionTile(
            icon: Iconsax.user,
            iconColor: AppColors.primary,
            title: "edit_information".tr,
            subtitle: "edit_information_subtitle".tr,
            onTap: onEditInfo,
          ),
          _hairline(isDark),
          _ActionTile(
            icon: Iconsax.lock_1,
            iconColor: const Color(0xFFF59E0B),
            title: "change_password".tr,
            subtitle: "change_password_subtitle".tr,
            onTap: onChangePassword,
          ),
          _hairline(isDark),
          _ActionTile(
            icon: Iconsax.camera,
            iconColor: const Color(0xFF3B82F6),
            title: "change_photo".tr,
            subtitle: "change_photo_subtitle".tr,
            onTap: onChangePhoto,
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

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLast;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  double _scale = 1.0;

  void _setPressed(bool pressed) => setState(() => _scale = pressed ? 0.97 : 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, widget.isLast ? 16 : 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(widget.icon, size: 18, color: widget.iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(widget.title, fontSize: 12.5, fontWeight: FontWeight.w600),
                    const SizedBox(height: 3),
                    AppText(
                      widget.subtitle,
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.55),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Icon( Get.locale?.languageCode == 'ar' ? Iconsax.arrow_circle_left_copy    : Iconsax.arrow_circle_right_copy, size: 16, color: Colors.grey.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}