import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/MerchantModel.dart';

/// Opens a modern, premium bottom sheet with the full details of a
/// [LoyaltyProgram]: its type, tuning values (points/stamps/cashback),
/// and its reward, if any.
Future<void> showClubProgramDetailsSheet(
  BuildContext context, {
  required LoyaltyProgram program,
  String? currencyCode,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProgramDetailsSheet(program: program, currencyCode: currencyCode),
  );
}

class _ProgramDetailsSheet extends StatelessWidget {
  final LoyaltyProgram program;
  final String? currencyCode;

  const _ProgramDetailsSheet({required this.program, this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _modeAccent(program.mode);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                _dragHandle(isDark),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(isDark ? 0.16 : 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Icon(_modeIcon(program.mode), size: 22, color: accent),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              program.name,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.primary : AppColors.primaryDark,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(isDark ? 0.16 : 0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppText(
                                _modeLabelKey(program.mode).tr,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Iconsax.close_circle,
                            size: 17,
                            color: isDark ? AppColors.primary.withOpacity(0.7) : AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._rowsForMode(program).map(
                          (row) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _DetailRow(
                              icon: row.icon,
                              label: row.label.tr,
                              value: row.value,
                              accent: accent,
                              isDark: isDark,
                            ),
                          ),
                        ),
                        if (program.config.reward != null) ...[
                          const SizedBox(height: 6),
                          AppText(
                            'club_program_details_reward_title'.tr,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.primary.withOpacity(0.7) : AppColors.primaryLight,
                          ),
                          const SizedBox(height: 10),
                          _RewardCard(
                            reward: program.config.reward!,
                            accent: accent,
                            isDark: isDark,
                          ),
                        ],
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

  Widget _dragHandle(bool isDark) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.16) : Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  List<_DetailRowData> _rowsForMode(LoyaltyProgram program) {
    final config = program.config;
    final currencySuffix = currencyCode != null ? ' ${currencyCode!}' : '';

    switch (program.mode) {
      case ProgramMode.points:
        return [
          _DetailRowData(
            icon: Iconsax.coin,
            label: 'club_program_details_points_per_unit',
            value: '${config.pointsPerCurrencyUnit}',
          ),
          _DetailRowData(
            icon: Iconsax.award,
            label: 'club_program_details_points_per_reward',
            value: '${config.pointsPerReward}',
          ),
          _DetailRowData(
            icon: Iconsax.shopping_cart,
            label: 'club_program_details_min_purchase',
            value: '${config.minPurchase}$currencySuffix',
          ),
          _DetailRowData(
            icon: Iconsax.calendar_1,
            label: 'club_program_details_expiry',
            value: '${config.pointsExpiryDays} ${'club_program_details_days'.tr}',
          ),
        ];
      case ProgramMode.stamps:
        return [
          _DetailRowData(
            icon: Iconsax.ticket,
            label: 'club_program_details_stamps_per_visit',
            value: '${config.stampsPerVisit}',
          ),
          _DetailRowData(
            icon: Iconsax.award,
            label: 'club_program_details_stamps_per_reward',
            value: '${config.stampsPerReward}',
          ),
          _DetailRowData(
            icon: Iconsax.calendar_1,
            label: 'club_program_details_expiry',
            value: '${config.stampsExpiryDays} ${'club_program_details_days'.tr}',
          ),
        ];
      case ProgramMode.cashback:
        return [
          _DetailRowData(
            icon: Iconsax.percentage_square,
            label: 'club_program_details_cashback_percent',
            value: '${config.cashbackPercent}%',
          ),
          _DetailRowData(
            icon: Iconsax.shopping_cart,
            label: 'club_program_details_min_purchase',
            value: '${config.cashbackMinPurchase}$currencySuffix',
          ),
          _DetailRowData(
            icon: Iconsax.calendar_1,
            label: 'club_program_details_expiry',
            value: '${config.cashbackExpiryDays} ${'club_program_details_days'.tr}',
          ),
        ];
      case ProgramMode.unknown:
        return const [];
    }
  }

  Color _modeAccent(ProgramMode mode) {
    switch (mode) {
      case ProgramMode.points:
        return const Color(0xFFE0A324);
      case ProgramMode.stamps:
        return const Color(0xFF3D8BFD);
      case ProgramMode.cashback:
        return const Color(0xFF2FB380);
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

  String _modeLabelKey(ProgramMode mode) {
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

class _DetailRowData {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRowData({required this.icon, required this.label, required this.value});
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.025),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(isDark ? 0.16 : 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              label,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.primary.withOpacity(0.7) : AppColors.primaryLight,
            ),
          ),
          AppText(
            value,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.primary : AppColors.primaryDark,
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final ProgramReward reward;
  final Color accent;
  final bool isDark;

  const _RewardCard({required this.reward, required this.accent, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(isDark ? 0.18 : 0.12),
            accent.withOpacity(isDark ? 0.08 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(isDark ? 0.24 : 0.16), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(isDark ? 0.22 : 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(Iconsax.gift_copy, size: 19, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              reward.name,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.primary : AppColors.primaryDark,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}