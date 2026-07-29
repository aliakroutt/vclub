import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Auth/Models/ClientModel.dart';

/// Compact, centered profile summary — avatar with a gentle breathing glow,
/// name, and membership badge, set against a soft layered-circles backdrop
/// for a modern, premium feel. Replaces the old full-bleed parallax hero:
/// this is a flat card that sits directly in the scroll flow, matching the
/// grouped-sections layout of apps like Revolut, Wise, and N26.
class ProfileSummaryCard extends StatefulWidget {
  final ClientProfileModel? client;
  final VoidCallback? onChangeAvatar;

  const ProfileSummaryCard({
    super.key,
    required this.client,
    this.onChangeAvatar,
  });

  @override
  State<ProfileSummaryCard> createState() => _ProfileSummaryCardState();
}

class _ProfileSummaryCardState extends State<ProfileSummaryCard> with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final c = widget.client;
    if (c == null) return '';
    final f = c.firstName.trim();
    final l = c.lastName.trim();
    if (f.isEmpty && l.isEmpty) return '?';
    return ((f.isNotEmpty ? f[0] : '') + (l.isNotEmpty ? l[0] : '')).toUpperCase();
  }

  String get _fullName {
    final c = widget.client;
    if (c == null) return '-';
    final n = '${c.firstName} ${c.lastName}'.trim();
    return n.isEmpty ? '-' : n;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final avatarSize = (size.width * 0.24).clamp(84.0, 108.0);
    final client = widget.client;
    final isActive = client?.isActive ?? true;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? Colors.white.withOpacity(0.045) : Colors.white,
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 10))],
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.07)) : null,
      ),
      child: Stack(
        children: [
          // ---- Decorative layered circles backdrop ----
          Positioned(
            top: -size.width * 0.28,
            right: -size.width * 0.22,
            child: _circle(size.width * 0.62, AppColors.primary.withOpacity(isDark ? 0.10 : 0.07)),
          ),
          Positioned(
            top: -size.width * 0.1,
            right: -size.width * 0.04,
            child: _circle(size.width * 0.26, AppColors.primary.withOpacity(isDark ? 0.14 : 0.10)),
          ),
          Positioned(
            bottom: -size.width * 0.32,
            left: -size.width * 0.24,
            child: _circle(size.width * 0.55, AppColors.primary.withOpacity(isDark ? 0.08 : 0.05)),
          ),
          Positioned(
            bottom: -size.width * 0.04,
            left: -size.width * 0.02,
            child: _circle(size.width * 0.16, AppColors.primary.withOpacity(isDark ? 0.12 : 0.08)),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(
                color: (isDark ? Colors.white : AppColors.primary).withOpacity(isDark ? 0.025 : 0.03),
              ),
            ),
          ),

          // ---- Foreground content ----
          Padding(
            padding: EdgeInsets.symmetric(vertical: size.width * 0.08, horizontal: size.width * 0.05),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: widget.onChangeAvatar,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedBuilder(
                          animation: _glowCtrl,
                          builder: (context, child) {
                            final glow = 0.10 + (_glowCtrl.value * 0.12);
                            return Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: AppColors.primary.withOpacity(glow), blurRadius: 26, spreadRadius: 2),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withOpacity(0.35), width: 2),
                            ),
                            child: ClipOval(
                              child: (client?.avatar != null && client!.avatar!.isNotEmpty)
                                  ? Image.network(
                                      client.avatar!,
                                      width: avatarSize,
                                      height: avatarSize,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _fallback(avatarSize),
                                    )
                                  : _fallback(avatarSize),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.012),
                  AppText(_fullName, fontSize: 19, fontWeight: FontWeight.w800),
                  const SizedBox(height: 4),
                  AppText(
                    client?.email.isNotEmpty == true ? client!.email : '-',
                    fontSize: 12.5,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isActive ? AppColors.primary : Colors.orange).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? AppColors.primary : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 7),
                        AppText(
                          (isActive ? 'vclub_member' : 'inactive_member').tr,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isActive ? AppColors.primary : Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  Widget _fallback(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.55)]),
        ),
        alignment: Alignment.center,
        child: AppText(_initials, fontSize: size * 0.32, fontWeight: FontWeight.w800, color: Colors.white),
      );
}

/// Extremely subtle dotted grid, adds a tactile texture behind the circles
/// without needing image assets.
class _DotGridPainter extends CustomPainter {
  final Color color;
  const _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 20.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => oldDelegate.color != color;
}