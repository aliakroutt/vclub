import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class CompanyHeaderCard extends StatelessWidget {
  const CompanyHeaderCard({
    super.key,
    required this.companyName,
    required this.companyId,
    required this.isActive,
    this.isPremium = true,
  });

  final String companyName;
  final String companyId;
  final bool isActive;
  final bool isPremium;

  static const _accent = Color(0xFF7C6FF7);
  static const _activeColor = Color(0xFF00C896);
  static const _inactiveColor = Color(0xFFFF6B6B);
  static const _goldColor = Color(0xFFFFB930);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstLetter =
        companyName.isNotEmpty ? companyName[0].toUpperCase() : '?';

    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withOpacity(.07)
        : Colors.black.withOpacity(.06);

    return Container(
      padding: EdgeInsets.all(size.width * .046),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: surfaceColor,
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .30 : .06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _accent.withOpacity(isDark ? .07 : .04),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// ── AVATAR ────────────────────────────────────────
          _Avatar(letter: firstLetter, size: size.width * .13),

          SizedBox(width: size.width * .04),

          /// ── INFO ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Name row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AppText(
                        companyName,
                        fontSize: size.width * .043,
                        fontWeight: FontWeight.w800,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusDot(isActive: isActive),
                  ],
                ),

                SizedBox(height: size.height * .005),

                /// ID + Premium row
                Row(
                  children: [
                    Icon(Iconsax.hashtag, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 3),
                    Expanded(
                      child: AppText(
                        companyId,
                        fontSize: size.width * .031,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 8),
                      _PremiumChip(),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── AVATAR ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter, required this.size});
  final String letter;
  final double size;

  static const _accent = Color(0xFF7C6FF7);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _accent.withOpacity(.22),
            _accent.withOpacity(.06),
          ],
        ),
        border: Border.all(color: _accent.withOpacity(.22), width: 1.5),
      ),
      child: Center(
        child: AppText(
          letter,
          fontSize: size * .44,
          fontWeight: FontWeight.w900,
          color: _accent,
        ),
      ),
    );
  }
}

// ── STATUS DOT ────────────────────────────────────────────────────────────────
// Replaces the verbose badge with a tight pill — keeps the name row clean.

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? const Color(0xFF00C896) : const Color(0xFFFF6B6B);
    final label = isActive ? 'Active' : 'Inactive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withOpacity(.10),
        border: Border.all(color: color.withOpacity(.22), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          AppText(
            label,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }
}

// ── PREMIUM CHIP ──────────────────────────────────────────────────────────────

class _PremiumChip extends StatelessWidget {
  const _PremiumChip();

  static const _gold = Color(0xFFFFB930);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: _gold.withOpacity(.10),
        border: Border.all(color: _gold.withOpacity(.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.diamonds, size: 11, color: _gold),
          const SizedBox(width: 4),
          AppText(
            'Premium',
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: _gold,
          ),
        ],
      ),
    );
  }
}