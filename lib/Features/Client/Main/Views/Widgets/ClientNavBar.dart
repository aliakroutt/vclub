import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Client/Main/Controllers/MainController.dart';
import 'dart:ui';

class VClubBottomNavBar extends StatelessWidget {
  final MainController controller;

  const VClubBottomNavBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final double navBarWidth = size.width > 600
        ? size.width * 0.55
        : size.width * 0.88;
    final double itemSize = size.width > 600 ? 54.0 : 48.0;
    final double iconSize = size.width > 600 ? 23.0 : 21.0;

    return Obx(
      () => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: bottomPad > 0 ? bottomPad + 10 : 22,
            left: 24,
            right: 24,
          ),
          child: SizedBox(
            width: navBarWidth,
            child: _GlassNavPill(
              isDark: isDark,
              itemSize: itemSize,
              iconSize: iconSize,
              selectedIndex: controller.selectedIndex.value,
              onTap: controller.selectIndex,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavPill extends StatelessWidget {
  final bool isDark;
  final double itemSize;
  final double iconSize;
  final int selectedIndex;
  final void Function(int) onTap;

  const _GlassNavPill({
    required this.isDark,
    required this.itemSize,
    required this.iconSize,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Iconsax.home_2, activeIcon: Iconsax.home, label: 'Home'),
    (icon: Iconsax.card, activeIcon: Iconsax.card, label: 'Cards'),
    (icon: Iconsax.gift, activeIcon: Iconsax.gift, label: 'Gifts'),
    (icon: Iconsax.user, activeIcon: Iconsax.profile_circle, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        // ── Softer, more realistic ambient depth (matches GlassNavBar) ──
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 35,
            spreadRadius: -10,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            spreadRadius: -6,
            offset: const Offset(0, 6),
          ),
          // ✨ subtle brand glow
          BoxShadow(
            color: AppColors.primary.withOpacity(0.14),
            blurRadius: 26,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          // 🎯 more natural iOS blur range
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              // 🌫️ REAL glass material tint (same as GlassNavBar)
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.08),
                ],
              ),
              // 🧊 glass edge definition
              border: Border.all(
                color: Colors.white.withOpacity(0.16),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _items.length,
                (i) => _NavItem(
                  icon: _items[i].icon,
                  activeIcon: _items[i].activeIcon,
                  label: _items[i].label,
                  isSelected: selectedIndex == i,
                  isDark: isDark,
                  size: itemSize,
                  iconSize: iconSize,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(i);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.10,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    if (widget.isSelected) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _ctrl.forward(from: 0);
    } else if (!widget.isSelected && old.isSelected) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Transform.scale(
          scale: _scaleAnim.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Selected: frosted glass bubble ─────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  width: widget.isSelected ? widget.size * 0.78 : 0,
                  height: widget.isSelected ? widget.size * 0.78 : 0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    // 🔥 glass highlight instead of solid glow
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(widget.isDark ? 0.08 : 0.25),
                        Colors.transparent,
                      ],
                    ),

                    border: widget.isSelected
                        ? Border.all(
                            color: AppColors.primary.withOpacity(
                              widget.isDark ? 0.35 : 0.25,
                            ),
                            width: 1.2,
                          )
                        : null,

                    boxShadow: widget.isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(
                                widget.isDark ? 0.25 : 0.18,
                              ),
                              blurRadius: 18,
                              spreadRadius: -2,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                ),

                // ── Icon: outlined → filled swap ───────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    );
                  },

                  child: Icon(
                    widget.isSelected ? widget.activeIcon : widget.icon,
                    // 🔥 IMPORTANT FIX: stable key
                    key: ValueKey('${widget.label}_${widget.isSelected}'),
                    size: widget.iconSize,
                    color: widget.isSelected
                        ? AppColors.primary
                        : Colors.white,
                  ),
                ),

                // ── Dot indicator ──────────────────────────────────
                Positioned(
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: widget.isSelected ? 14 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
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