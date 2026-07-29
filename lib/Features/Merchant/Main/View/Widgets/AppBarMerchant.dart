import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Main/Views/Widgets/AppBarLanguageSelector.dart';

class MainAppBarMerchant extends StatefulWidget implements PreferredSizeWidget {
  final ThemeService themeService;
  final VoidCallback onLogout;

  const MainAppBarMerchant({
    super.key,
    required this.themeService,
    required this.onLogout,
  });

  @override
  State<MainAppBarMerchant> createState() => _MainAppBarMerchantState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _MainAppBarMerchantState extends State<MainAppBarMerchant>
    with SingleTickerProviderStateMixin {
  late final AnimationController _themeAnimController;
  late final Animation<double> _themeRotation;

  @override
  void initState() {
    super.initState();
    _themeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _themeRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
          parent: _themeAnimController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _themeAnimController.dispose();
    super.dispose();
  }

  void _handleThemeToggle() {
    _themeAnimController.isCompleted
        ? _themeAnimController.reverse()
        : _themeAnimController.forward();
    widget.themeService.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(() {
      // Read observable HERE at the top — GetX tracks it correctly
      final isDark = widget.themeService.isDarkMode.value;

      return Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.03,
          vertical: 8,
        ),
        child: SafeArea(
          bottom: false,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 54,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.80),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.10)
                        : Colors.black.withOpacity(0.07),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(isDark ? 0.25 : 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // ── Menu button ──────────────────────
                      _MenuButton(isDark: isDark),
                      const Spacer(),
                      // ── Theme toggle ─────────────────────
                      _AnimatedThemeButton(
                        isDark: isDark,
                        rotationAnimation: _themeRotation,
                        onTap: _handleThemeToggle,
                      ),
                      const SizedBox(width: 8),
                      // ── Language selector ─────────────────
                      const AppBarLanguageSelector(),
                      const SizedBox(width: 8),
                      // ── Logout ────────────────────────────
                      _AppBarButton(
                        icon: Iconsax.logout,
                        isDark: isDark,
                        isDanger: true,
                        onTap: widget.onLogout,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
//  Menu button
// ─────────────────────────────────────────────────────────────

class _MenuButton extends StatefulWidget {
  final bool isDark;
  const _MenuButton({required this.isDark});

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        if (context.mounted) Scaffold.of(context).openDrawer();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.25),
              width: 0.5,
            ),
          ),
          child: Icon(Iconsax.menu_1, size: 19, color: AppColors.primary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Generic icon button
// ─────────────────────────────────────────────────────────────

class _AppBarButton extends StatefulWidget {
  final IconData icon;
  final bool isDark;
  final bool isDanger;
  final VoidCallback onTap;

  const _AppBarButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_AppBarButton> createState() => _AppBarButtonState();
}

class _AppBarButtonState extends State<_AppBarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _iconColor {
    if (widget.isDanger) return Colors.redAccent;
    return widget.isDark
        ? Colors.white.withOpacity(0.65)
        : Colors.black.withOpacity(0.5);
  }

  Color get _bgColor {
    if (widget.isDanger) {
      return Colors.redAccent.withOpacity(widget.isDark ? 0.12 : 0.08);
    }
    return widget.isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.black.withOpacity(0.04);
  }

  Color get _borderColor {
    if (widget.isDanger) return Colors.redAccent.withOpacity(0.25);
    return widget.isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.07);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor, width: 0.5),
          ),
          child: Icon(widget.icon, size: 19, color: _iconColor),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Theme toggle button with spin animation
// ─────────────────────────────────────────────────────────────

class _AnimatedThemeButton extends StatefulWidget {
  final bool isDark;
  final Animation<double> rotationAnimation;
  final VoidCallback onTap;

  const _AnimatedThemeButton({
    required this.isDark,
    required this.rotationAnimation,
    required this.onTap,
  });

  @override
  State<_AnimatedThemeButton> createState() => _AnimatedThemeButtonState();
}

class _AnimatedThemeButtonState extends State<_AnimatedThemeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _pressScale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.primary;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) async {
        await _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: RotationTransition(
          turns: widget.rotationAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(widget.isDark ? 0.15 : 0.09),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accent.withOpacity(widget.isDark ? 0.30 : 0.22),
                width: 0.5,
              ),
            ),
            child: Icon(
              widget.isDark ? Iconsax.sun_1 : Iconsax.moon,
              size: 19,
              color: accent,
            ),
          ),
        ),
      ),
    );
  }
}