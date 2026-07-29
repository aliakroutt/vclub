import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class GlassNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onAddTap;
  final VoidCallback onRedeemTap;

  const GlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddTap,
    required this.onRedeemTap,
  });

  @override
  State<GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _menuCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
  );
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  static const _items = [
    _NavMeta(icon: Iconsax.home_1, activeIcon: Iconsax.home, label: 'Home'),
    _NavMeta(icon: Iconsax.crown_1, activeIcon: Iconsax.crown, label: 'Loyalty'),
    _NavMeta(
      icon: Iconsax.profile_2user,
      activeIcon: Iconsax.profile_circle,
      label: 'Users',
    ),
    _NavMeta(icon: Iconsax.setting_2, activeIcon: Iconsax.setting, label: 'Settings'),
  ];

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _menuCtrl.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    HapticFeedback.mediumImpact();
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final itemSize = width > 600 ? 54.0 : 50.0;
    final bottomSafe = mq.padding.bottom;
    final navBottomPad = bottomSafe > 0 ? bottomSafe + 10 : 24;
    final circleSize = itemSize * 1.18; // same size as the scan FAB
    // Roughly clears the pill height + the FAB's upward protrusion + a gap.
    final circlesBottom = navBottomPad + itemSize + (itemSize * 0.44) + 18;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _ScanActionMenu(
        controller: _menuCtrl,
        bottomOffset: circlesBottom,
        circleSize: circleSize,
        onAdd: () {
          _closeMenu();
          widget.onAddTap();
        },
        onRedeem: () {
          _closeMenu();
          widget.onRedeemTap();
        },
        onDismiss: _closeMenu,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _menuCtrl.forward(from: 0);
  }

  Future<void> _closeMenu() async {
    if (_overlayEntry == null) return;
    await _menuCtrl.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.of(context).size.width;
    final pillW = width > 600 ? width * 0.55 : width * 0.90;
    final itemSize = width > 600 ? 54.0 : 50.0;
    final iconSize = width > 600 ? 23.0 : 21.0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottom > 0 ? bottom + 10 : 24,
        left: 16,
        right: 16,
      ),
      child: Center(
        child: SizedBox(
          width: pillW,
          child: _GlassPill(
            items: _items,
            selectedIndex: widget.selectedIndex,
            onTap: widget.onItemTapped,
            onScanTap: _toggleMenu,
            isMenuOpen: _isOpen,
            itemSize: itemSize,
            iconSize: iconSize,
          ),
        ),
      ),
    );
  }
}

// ─── Glass pill container ──────────────────────────────────────────────────────
class _GlassPill extends StatelessWidget {
  final List<_NavMeta> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onScanTap;
  final bool isMenuOpen;
  final double itemSize;
  final double iconSize;

  const _GlassPill({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.onScanTap,
    required this.isMenuOpen,
    required this.itemSize,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // ── shadow layer ──────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
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
              BoxShadow(
                color: AppColors.primary.withOpacity(0.14),
                blurRadius: 26,
                spreadRadius: -10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.14),
                      Colors.white.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _GlassNavItem(
                      meta: items[0],
                      isSelected: selectedIndex == 0,
                      size: itemSize,
                      iconSize: iconSize,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(0);
                      },
                    ),
                    _GlassNavItem(
                      meta: items[1],
                      isSelected: selectedIndex == 1,
                      size: itemSize,
                      iconSize: iconSize,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(1);
                      },
                    ),
                    SizedBox(width: itemSize),
                    _GlassNavItem(
                      meta: items[2],
                      isSelected: selectedIndex == 4,
                      size: itemSize,
                      iconSize: iconSize,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(2);
                      },
                    ),
                    _GlassNavItem(
                      meta: items[3],
                      isSelected: selectedIndex == 9,
                      size: itemSize,
                      iconSize: iconSize,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(3);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── floating scan / close FAB ─────────────────────────────
        Positioned(
          top: -(itemSize * 0.44),
          child: _ScanFab(
            size: itemSize * 1.18,
            iconSize: iconSize + 4,
            isOpen: isMenuOpen,
            onTap: onScanTap,
          ),
        ),
      ],
    );
  }
}

// ─── Scan / close FAB ───────────────────────────────────────────────────────────
class _ScanFab extends StatefulWidget {
  final double size;
  final double iconSize;
  final bool isOpen;
  final VoidCallback onTap;

  const _ScanFab({
    required this.size,
    required this.iconSize,
    required this.isOpen,
    required this.onTap,
  });

  @override
  State<_ScanFab> createState() => _ScanFabState();
}

class _ScanFabState extends State<_ScanFab> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
  );
  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.88)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary],
            ),
            border: Border.all(
              color: widget.isOpen ? Colors.white : AppColors.primaryDark,
              width: 3.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.45),
                blurRadius: 24,
                spreadRadius: -2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: Tween(begin: 0.75, end: 1.0).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              widget.isOpen ? Icons.close_rounded : Icons.qr_code_scanner_rounded,
              key: ValueKey(widget.isOpen),
              color: Colors.white,
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Floating Add / Redeem action menu (icon-only, stacked above the FAB) ──────
class _ScanActionMenu extends StatelessWidget {
  final AnimationController controller;
  final double bottomOffset;
  final double circleSize;
  final VoidCallback onAdd;
  final VoidCallback onRedeem;
  final VoidCallback onDismiss;

  const _ScanActionMenu({
    required this.controller,
    required this.bottomOffset,
    required this.circleSize,
    required this.onAdd,
    required this.onRedeem,
    required this.onDismiss,
  });

  static const _spacing = 14.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value.clamp(0.0, 1.0);
        return Stack(
          children: [
            // ── dim backdrop ──────────────────────────────────
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDismiss,
                child: Container(color: Colors.black.withOpacity(0.45 * t)),
              ),
            ),
            // ── Add (closest to the FAB) ───────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomOffset*1.1,
              child: Center(
                child: _AnimatedActionCircle(
                  t: controller.value,
                  delay: 0.0,
                  icon: Iconsax.add_circle,
                  color: AppColors.primary,
                  size: circleSize,
                  onTap: onAdd,
                ),
              ),
            ),
            // ── Redeem (stacked above Add) ─────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomOffset *1.1 + circleSize + _spacing,
              child: Center(
                child: _AnimatedActionCircle(
                  t: controller.value,
                  delay: 0.12,
                  icon: Iconsax.gift,
                  color: const Color(0xFFFFB930),
                  size: circleSize,
                  onTap: onRedeem,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Wraps a circle button with a staggered scale + fade + rise-up entrance,
/// driven off the shared [controller] value so the two icons animate in
/// sequence rather than together.
class _AnimatedActionCircle extends StatelessWidget {
  final double t;
  final double delay;
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _AnimatedActionCircle({
    required this.t,
    required this.delay,
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.75).clamp(0.0, 1.0);
    final bounce = Interval(delay, end, curve: Curves.easeOutBack).transform(t);
    final fadeEnd = (delay + 0.55).clamp(0.0, 1.0);
    final fade = Interval(delay, fadeEnd, curve: Curves.easeOut).transform(t);

    return Opacity(
      opacity: fade.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, (1 - bounce) * 30),
        child: Transform.scale(
          scale: (0.7 + 0.3 * bounce).clamp(0.0, 1.08),
          child: _PressableActionCircle(
            icon: icon,
            color: color,
            size: size,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

/// A round icon button matching the scan FAB's visual language — same
/// gradient-fill + glow-shadow treatment, just a different accent color.
class _PressableActionCircle extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _PressableActionCircle({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  State<_PressableActionCircle> createState() => _PressableActionCircleState();
}

class _PressableActionCircleState extends State<_PressableActionCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.88)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.color, widget.color.withOpacity(0.82)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.55), width: 2.2),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.45),
                blurRadius: 22,
                spreadRadius: -2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: widget.size * .42),
        ),
      ),
    );
  }
}

// ─── Nav item ─────────────────────────────────────────────────────────────────
class _GlassNavItem extends StatefulWidget {
  final _NavMeta meta;
  final bool isSelected;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.meta,
    required this.isSelected,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  @override
  State<_GlassNavItem> createState() => _GlassNavItemState();
}

class _GlassNavItemState extends State<_GlassNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  late final Animation<double> _scale = Tween(begin: 1.0, end: 1.10)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

  static const _accent = AppColors.primary;

  @override
  void initState() {
    super.initState();
    if (widget.isSelected) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_GlassNavItem old) {
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
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: widget.isSelected ? widget.size * 0.78 : 0,
                height: widget.isSelected ? widget.size * 0.78 : 0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.transparent,
                  ]),
                  border: widget.isSelected
                      ? Border.all(color: _accent.withOpacity(0.32), width: 1.2)
                      : null,
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: _accent.withOpacity(0.25),
                            blurRadius: 18,
                            spreadRadius: -2,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 210),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(scale: anim, child: child),
                ),
                child: Icon(
                  widget.isSelected ? widget.meta.activeIcon : widget.meta.icon,
                  key: ValueKey('${widget.meta.label}_${widget.isSelected}'),
                  size: widget.iconSize,
                  color: widget.isSelected ? _accent : Colors.white,
                ),
              ),
              Positioned(
                bottom: 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  width: widget.isSelected ? 14 : 0,
                  height: 2,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: _accent.withOpacity(0.55), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────
class _NavMeta {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavMeta({required this.icon, required this.activeIcon, required this.label});
}