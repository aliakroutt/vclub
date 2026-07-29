import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/MerchantModel.dart';
import 'package:vclub/Features/Client/ClubsClient/View/Clubs.dart' show ClubViewerRole;



/// A single loyalty program card (points / stamps / cashback), shown
/// inside the programs list on [ClubScreen].
///
/// - Every role sees the name, type badge, and a "Details" button.
/// - Only [ClubViewerRole.client] additionally sees either a "Join"
///   button or an "Already joined" indicator, depending on [isJoined].
class ClubProgramCard extends StatelessWidget {
  final LoyaltyProgram program;
  final ClubViewerRole role;
  final bool isJoined;
  final VoidCallback onDetails;
  final VoidCallback? onJoin;

  const ClubProgramCard({
    super.key,
    required this.program,
    required this.role,
    this.isJoined = false,
    required this.onDetails,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _modeAccent(program.mode);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withOpacity(isDark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Icon(_modeIcon(program.mode), size: 20, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      program.name,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.primary : AppColors.primaryDark,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _TypeBadge(mode: program.mode, accent: accent),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetails,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.14) : Colors.black.withOpacity(0.10),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: AppText(
                    'club_program_card_details_button'.tr,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primary : AppColors.primaryDark,
                  ),
                ),
              ),
              if (role == ClubViewerRole.client) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: isJoined ? _AlreadyJoinedPill() : _JoinButton(accent: accent, onTap: onJoin),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _modeAccent(ProgramMode mode) {
    switch (mode) {
      case ProgramMode.points:
        return const Color(0xFFE0A324); // gold
      case ProgramMode.stamps:
        return const Color(0xFF3D8BFD); // blue
      case ProgramMode.cashback:
        return const Color(0xFF2FB380); // green
      case ProgramMode.unknown:
        return AppColors.primary;
    }
  }

  IconData _modeIcon(ProgramMode mode) {
    switch (mode) {
      case ProgramMode.points:
        return Iconsax.star_copy;
      case ProgramMode.stamps:
        return Iconsax.ticket_copy;
      case ProgramMode.cashback:
        return Iconsax.wallet_money_copy;
      case ProgramMode.unknown:
        return Iconsax.award_copy;
    }
  }
}

class _TypeBadge extends StatelessWidget {
  final ProgramMode mode;
  final Color accent;

  const _TypeBadge({required this.mode, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        _labelKey(mode).tr,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: accent,
      ),
    );
  }

  String _labelKey(ProgramMode mode) {
    switch (mode) {
      case ProgramMode.points:
        return 'club_program_type_points';
      case ProgramMode.stamps:
        return 'club_program_type_stamps';
      case ProgramMode.cashback:
        return 'club_program_type_cashback';
      case ProgramMode.unknown:
        return 'club_program_type_unknown';
    }
  }
}

class _JoinButton extends StatelessWidget {
  final Color accent;
  final VoidCallback? onTap;

  const _JoinButton({required this.accent, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 10),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: AppText(
        'club_program_card_join_button'.tr,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

class _AlreadyJoinedPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.tick_circle_copy,
            size: 14,
            color: isDark ? AppColors.primary.withOpacity(0.7) : AppColors.primaryLight,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: AppText(
              'club_program_card_already_joined'.tr,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.primary.withOpacity(0.7) : AppColors.primaryLight,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}