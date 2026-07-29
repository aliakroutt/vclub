import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/MerchantModel.dart';


/// Premium hero header shown at the top of [ClubScreen], for every
/// viewer role. A gradient "card" with soft decorative circles in the
/// background, a glass-effect initial avatar, the merchant name, and a
/// glass pill badge with the number of loyalty programs.
class ClubHeader extends StatelessWidget {
  final Merchant merchant;

  const ClubHeader({
    super.key,
    required this.merchant,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _resolveAccentColor();
    final gradientEnd = Color.lerp(accent, Colors.black, 0.28)!;
    final programsCount = merchant.programs.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, gradientEnd],
          ),
         boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ], 

        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative background circles for a premium, layered feel.
            Positioned(
              top: -46,
              right: -34,
              child: _decorativeCircle(size: 160, opacity: 0.10),
            ),
            Positioned(
              bottom: -60,
              left: -30,
              child: _decorativeCircle(size: 130, opacity: 0.08),
            ),
            // Positioned(
            //   top: 30,
            //   right: 60,
            //   child: _decorativeCircle(
            //     size: 46,
            //     opacity: 0.14,
            //     outlineOnly: true,
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _GlassAvatar(letter: _initial),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          merchant.name,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        _ProgramsBadge(count: programsCount),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorativeCircle({
    required double size,
    required double opacity,
    bool outlineOnly = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: outlineOnly ? Colors.transparent : Colors.white.withOpacity(opacity),
        border: outlineOnly
            ? Border.all(color: Colors.white.withOpacity(opacity), width: 1.4)
            : null,
      ),
    );
  }

  String get _initial {
    final name = merchant.name.trim();
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  Color _resolveAccentColor() {
    final hex = merchant.brandColor;
    if (hex == null || hex.isEmpty) return AppColors.primary;

    try {
      var value = hex.replaceAll('#', '');
      if (value.length == 6) value = 'FF$value';
      return Color(int.parse(value, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

class _GlassAvatar extends StatelessWidget {
  final String letter;

  const _GlassAvatar({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.16),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
      ),
      alignment: Alignment.center,
      child: AppText(
        letter,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

class _ProgramsBadge extends StatelessWidget {
  final int count;

  const _ProgramsBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.28), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.award_copy, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          AppText(
            '$count ${'club_header_programs_label'.tr}',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}