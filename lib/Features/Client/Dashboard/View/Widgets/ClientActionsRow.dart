import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';

class ClientActionsColumn extends StatelessWidget {
  final VoidCallback onFortuneWheelTap;
  final VoidCallback onGoogleReviewTap;

  const ClientActionsColumn({
    super.key,
    required this.onFortuneWheelTap,
    required this.onGoogleReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final isRTL = Get.locale?.languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    final actions = [
      {
        "title": 'fortune_wheel_client'.tr,
        "icon": Iconsax.gift,
        "color": AppColors.primary,
        "onTap": onFortuneWheelTap,
      },
      {
        "title": 'google_review_client'.tr,
        "icon": Iconsax.google_copy,
        "color": const Color(0xFFFF9800),
        "onTap": onGoogleReviewTap,
      },
    ];

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        children: List.generate(
          actions.length,
          (i) => Padding(
            padding: EdgeInsets.only(
              bottom: i == actions.length - 1 ? 0 : size.height * 0.015,
            ),
            child: _ActionCard(
              title: actions[i]["title"] as String,
              icon: actions[i]["icon"] as IconData,
              color: actions[i]["color"] as Color,
              isDark: isDark,
              onTap: actions[i]["onTap"] as VoidCallback,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color = widget.color;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final isDark = widget.isDark;

    // Text/title stays legible on a light tinted surface in both themes —
    // dark mode leans on the near-white theme text, light mode deepens
    // the accent color itself for the label instead of using pure black.
    final labelColor = isDark
        ? Colors.white.withOpacity(0.92)
        : Color.lerp(color, Colors.black, 0.35)!;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          height: size.height * 0.068,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withOpacity(isDark ? 0.14 : 0.10),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.4 : 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isDark ? 0.18 : 0.12),
                blurRadius: 20,
                spreadRadius: -6,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // faint decorative circle, echoes the icon shape — barely
              // visible, just adds depth without competing with content
              Positioned(
                top: -size.width * 0.14,
                right: isRTL ? null : -size.width * 0.08,
                left: isRTL ? -size.width * 0.08 : null,
                child: Container(
                  width: size.width * 0.28,
                  height: size.width * 0.28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(isDark ? 0.08 : 0.05),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ICON — solid tinted badge, the one saturated element
                    // on the card so it still reads as an accent color
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.024),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(isDark ? 0.22 : 0.16),
                          border: Border.all(
                            color: color.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          size: size.width * 0.05,
                          color: color,
                        ),
                      ),
                    ),

                    SizedBox(width: size.width * 0.04),

                    // TEXT
                    Expanded(
                      child: AppText(
                        widget.title,
                        fontSize: size.width * 0.037,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                        color: labelColor,
                      ),
                    ),

                    // ARROW
                    Container(
                      padding: EdgeInsets.all(size.width * 0.016),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(isDark ? 0.16 : 0.12),
                      ),
                      child: Icon(
                        isRTL
                            ? Iconsax.arrow_circle_left_copy
                            : Iconsax.arrow_circle_right_copy,
                        size: size.width * 0.038,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}