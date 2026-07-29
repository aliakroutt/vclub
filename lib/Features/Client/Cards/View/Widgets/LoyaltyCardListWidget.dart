import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Cards/Controllers/ClientCradsController.dart';
import 'package:vclub/Features/Client/Cards/View/CardDetails.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/AppShimmer.dart';

// =========================
// PUBLIC ENTRY WIDGET
// =========================
class LoyaltyCardsList extends StatelessWidget {
  const LoyaltyCardsList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientCardsController.to;
    final isDark = Get.find<ThemeService>().isDarkMode.value;

    return Obx(() {
      final isLoading = controller.cardsLoading.value;
      final hasError = controller.cardsError.value.isNotEmpty;
      final cards = controller.filteredCards;

      // ---------- LOADING ----------
      if (isLoading && controller.cards.isEmpty) {
        return ListView(
          padding: const EdgeInsets.only(bottom: 30),
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ShimmerLoyaltyCard(isDark: isDark),
            ),
          ),
        );
      }

      // ---------- ERROR (no cached data) ----------
      if (hasError && controller.cards.isEmpty) {
        return _CardsErrorState(
          isDark: isDark,
          onRetry: () => controller.fetchCards(),
        );
      }

      // ---------- EMPTY (no results for current filters) ----------
      if (cards.isEmpty) {
        return _CardsEmptyState(
          isDark: isDark,
          isFiltered: controller.hasActiveFilters,
          onClearFilters: controller.clearFilters,
        );
      }

      // ---------- LOADED ----------
      return ListView.separated(
        padding: const EdgeInsets.only(bottom: 30),
        shrinkWrap: true,
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final c = cards[index];
          return OpenContainer(
            transitionType: ContainerTransitionType.fadeThrough,
            transitionDuration: const Duration(milliseconds: 500),
            closedElevation: 0,
            openElevation: 0,
            closedColor: Colors.transparent,
            openColor: Colors.transparent,
           
            closedBuilder: (context, openContainer) {
              return GestureDetector(
                onTap: openContainer,
                child: LoyaltyCardView(card: c),
              );
            },
            openBuilder: (context, closeContainer) => CardDetails(card: c),
          );
        },
      );
    });
  }
}

// =========================
// MODE → ICON / COLOR
// =========================
class _ModeMeta {
  final IconData icon;
  final Color color;
  const _ModeMeta(this.icon, this.color);
}

_ModeMeta _metaForMode(String mode) {
  switch (mode) {
    case 'stamps':
      return const _ModeMeta(Iconsax.award, Color(0xFF29B6F6));
    case 'cashback':
      return const _ModeMeta(Iconsax.money_recive, Color(0xFF4CAF50));
    case 'points':
    default:
      return const _ModeMeta(Iconsax.star_1, Color(0xFFFFB300));
  }
}

double _safeProgress(num value, num target) {
  if (target <= 0) return 0.0;
  return (value / target).clamp(0.0, 1.0).toDouble();
}

String _percentText(double progress) =>
    '${(progress * 100).toStringAsFixed(0)}%';

// =========================
// CARD
// =========================
class LoyaltyCardView extends StatelessWidget {
  final VoidCallback? onClaimReward;
  final ClientCardModel card;

  const LoyaltyCardView({
    super.key,
    required this.card,
    this.onClaimReward,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final meta = _metaForMode(card.program.mode);
    final accent = meta.color;

    return  Hero(
        tag: 'loyalty-card-${card.id}',
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).cardColor,
                Color.alphaBlend(
                  accent.withOpacity(0.05),
                  Theme.of(context).cardColor,
                ),
              ],
            ),
            border: Border.all(width: 1, color: accent.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.18),
                blurRadius: 24,
                spreadRadius: -6,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -30,
                child: _circle(accent.withOpacity(0.10), 130),
              ),
              Positioned(
                bottom: -55,
                left: -35,
                child: _circle(accent.withOpacity(0.06), 140),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 60,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.06),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(size.width * 0.045),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CardHeader(card: card, accent: accent, icon: meta.icon),
                    SizedBox(height: size.height * 0.02),
                    _CardBody(card: card, accent: accent),
                    SizedBox(height: size.height * 0.015),
                    _CardFooter(card: card, accent: accent),
                    if (_isRewardReady(card)) ...[
                      SizedBox(height: size.height * 0.016),
                      _ClaimRewardButton(
                        accent: accent,
                        card: card,
                        onTap: onClaimReward,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      
    );
  }
  bool _isRewardReady(ClientCardModel card) {
  switch (card.program.mode) {
    case 'points':
      return card.program.pointsPerReward > 0 &&
          card.points >= card.program.pointsPerReward;
    case 'stamps':
      return card.program.stampsPerReward > 0 &&
          card.stamps >= card.program.stampsPerReward;
    case 'cashback':
      // No numeric reward-threshold field for cashback on ProgramModel
      // (cashbackMinPurchase is the earn-rate minimum, not a payout target).
      return card.cardCompleted;
    default:
      return card.cardCompleted;
  }
}

  Widget _circle(Color color, double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _ClaimRewardButton extends StatelessWidget {
  final Color accent;
  final ClientCardModel card;
  final VoidCallback? onTap;

  const _ClaimRewardButton({
    required this.accent,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap?.call();
          showLoyaltyRewardQrDialog(context, card: card, accent: accent);
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.014),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [accent, Color.lerp(accent, Colors.white, 0.18)!],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.40),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.gift_copy,
                size: size.width * 0.045,
                color: Colors.white,
              ),
              SizedBox(width: size.width * 0.02),
              AppText(
                'claim_reward_client'.tr,
                fontSize: size.width * 0.035,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showLoyaltyRewardQrDialog(
  BuildContext context, {
  required ClientCardModel card,
  required Color accent,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Transform.scale(
        scale: 0.9 + (0.1 * curved.value),
        child: Opacity(
          opacity: anim.value,
          child: _LoyaltyRewardQrDialog(card: card, accent: accent),
        ),
      );
    },
  );
}

class _LoyaltyRewardQrDialog extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;

  const _LoyaltyRewardQrDialog({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final dialogWidth = size.width < 480 ? size.width * 0.86 : 380.0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, Color.lerp(accent, Colors.black, 0.18)!],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.width * 0.022),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                      ),
                      child: Icon(
                        Iconsax.medal_star_copy,
                        color: Colors.white,
                        size: size.width * 0.055,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: AppText(
                        'loyalty_reward_title_client'.tr,
                        fontSize: size.width * 0.042,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.014),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.16),
                        ),
                        child: Icon(
                          Iconsax.close_circle,
                          color: Colors.white,
                          size: size.width * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.03,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.width * 0.035),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: accent.withOpacity(0.25),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.15),
                            blurRadius: 18,
                            spreadRadius: -4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: card.id,
                        version: QrVersions.auto,
                        size: dialogWidth * 0.56,
                        backgroundColor: Colors.white,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color.lerp(accent, Colors.black, 0.35)!,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.022),
                    AppText(
                      'claim_reward_instructions_client'.tr,
                      fontSize: size.width * 0.033,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      textAlign: TextAlign.center,
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

// =========================
// HEADER
// =========================
class _CardHeader extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  final IconData icon;

  const _CardHeader({
    required this.card,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CompanyIconBox(logo: card.company.logo, icon: icon, accent: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                card.company.name,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppText(
                card.program.name,
                fontSize: 12,
                color: Colors.grey.withOpacity(0.7),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _VisitsBadge(visits: card.visits, accent: accent),
            if (card.cardCompleted) ...[
              const SizedBox(height: 4),
              _RewardReadyChip(accent: accent),
            ],
          ],
        ),
      ],
    );
  }
}

class _CompanyIconBox extends StatelessWidget {
  final String logo;
  final IconData icon;
  final Color accent;

  const _CompanyIconBox({
    required this.logo,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.18), accent.withOpacity(0.08)],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: logo.isEmpty
          ? Icon(icon, color: accent, size: 20)
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(icon, color: accent, size: 20),
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Icon(icon, color: accent, size: 20),
              ),
            ),
    );
  }
}

class _VisitsBadge extends StatelessWidget {
  final int visits;
  final Color accent;
  const _VisitsBadge({required this.visits, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.repeat, size: 12, color: accent),
          const SizedBox(width: 4),
          AppText(
            '$visits',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ],
      ),
    );
  }
}

class _RewardReadyChip extends StatelessWidget {
  final Color accent;
  const _RewardReadyChip({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.gift, size: 11, color: Colors.white),
          const SizedBox(width: 3),
          AppText(
            'reward_ready_client'.tr,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

// =========================
// BODY
// =========================
class _CardBody extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _CardBody({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    switch (card.program.mode) {
      case 'stamps':
        return _StampsBody(card: card, accent: accent);
      case 'cashback':
        return _CashbackBody(card: card, accent: accent);
      case 'points':
      default:
        return _PointsBody(card: card, accent: accent);
    }
  }
}

class _PointsBody extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _PointsBody({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final target = card.program.pointsPerReward;
    final progress = _safeProgress(card.points, target);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [accent, accent.withOpacity(0.7)],
              ).createShader(bounds),
              child: AppText(
                '${card.points} ',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            AppText(
              target > 0
                  ? '/ $target ${'points_badge_client'.tr}'
                  : 'points_badge_client'.tr,
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        SizedBox(height: size.height * 0.012),
        _ProgressBar(progress: progress, accent: accent),
      ],
    );
  }
}

class _StampsBody extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _StampsBody({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    final target = card.program.stampsPerReward;
    final earned = card.stamps;
    final progress = _safeProgress(earned, target);
    final useDots = target > 0 && target <= 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [accent, accent.withOpacity(0.7)],
              ).createShader(bounds),
              child: AppText(
                '$earned ',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            AppText(
              target > 0
                  ? '/ $target ${'stamps_badge_client'.tr}'
                  : 'stamps_badge_client'.tr,
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (useDots)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(target, (i) {
              final filled = i < earned;
              return Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? accent : accent.withOpacity(0.12),
                  border: filled
                      ? null
                      : Border.all(color: accent.withOpacity(0.4)),
                ),
                child: filled
                    ? const Icon(Iconsax.award, size: 11, color: Colors.white)
                    : null,
              );
            }),
          )
        else
          _ProgressBar(progress: progress, accent: accent),
      ],
    );
  }
}

class _CashbackBody extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _CashbackBody({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'cashback_balance_client'.tr,
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [accent, accent.withOpacity(0.7)],
          ).createShader(bounds),
          child: AppText(
            '${card.cashbackBalance}€',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Iconsax.percentage_circle, size: 14, color: accent),
            const SizedBox(width: 4),
            Flexible(
              child: AppText(
                '${'cashback_earn_rate_client'.tr} ${card.program.cashbackPercent}%',
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color accent;
  const _ProgressBar({required this.progress, required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 8,
        width: double.infinity,
        color: Colors.grey.withOpacity(0.3),
        child: FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [accent.withOpacity(0.7), accent],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================
// FOOTER
// =========================
class _CardFooter extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _CardFooter({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    final mode = card.program.mode;
    String? trailingText;

    if (mode == 'points') {
      final target = card.program.pointsPerReward;
      if (target > 0)
        trailingText = _percentText(_safeProgress(card.points, target));
    } else if (mode == 'stamps') {
      final target = card.program.stampsPerReward;
      if (target > 0)
        trailingText = _percentText(_safeProgress(card.stamps, target));
    } else if (mode == 'cashback' && card.program.cashbackMinPurchase > 0) {
      trailingText =
          '${'cashback_min_purchase_client'.tr} ${card.program.cashbackMinPurchase}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: accent.withOpacity(0.12),
          ),
          child: AppText(
            card.tier.toUpperCase(),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
        if (trailingText != null)
          AppText(
            trailingText,
            fontWeight: FontWeight.w800,
            color: accent,
            fontSize: 14,
          ),
      ],
    );
  }
}

// =========================
// SHIMMER
// =========================
class _ShimmerLoyaltyCard extends StatelessWidget {
  final bool isDark;
  const _ShimmerLoyaltyCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AppShimmer(
      isDark: isDark,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.045),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBlock(width: 40, height: 40, radius: 14, isDark: isDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBlock(
                        width: size.width * 0.3,
                        height: 12,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 6),
                      ShimmerBlock(
                        width: size.width * 0.4,
                        height: 10,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                ShimmerBlock(width: 40, height: 20, radius: 20, isDark: isDark),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            ShimmerBlock(width: size.width * 0.3, height: 22, isDark: isDark),
            const SizedBox(height: 10),
            ShimmerBlock(
              width: double.infinity,
              height: 8,
              radius: 20,
              isDark: isDark,
            ),
            SizedBox(height: size.height * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBlock(width: 60, height: 20, radius: 12, isDark: isDark),
                ShimmerBlock(width: 40, height: 14, isDark: isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// ERROR STATE
// =========================
class _CardsErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _CardsErrorState({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.78),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        children: [
          const Icon(Iconsax.warning_2, color: Colors.redAccent, size: 28),
          const SizedBox(height: 8),
          AppText(
            'failed_load_cards'.tr,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: AppText(
              'retry'.tr,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// EMPTY STATE (filter-aware)
// =========================
class _CardsEmptyState extends StatelessWidget {
  final bool isDark;
  final bool isFiltered;
  final VoidCallback onClearFilters;

  const _CardsEmptyState({
    required this.isDark,
    required this.isFiltered,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.03),
      ),
      child: Column(
        children: [
          Icon(
            isFiltered ? Iconsax.filter_search : Iconsax.card,
            color: isDark ? Colors.white38 : Colors.black26,
            size: 30,
          ),
          const SizedBox(height: 8),
          AppText(
            isFiltered
                ? 'no_cards_match_filters_client'.tr
                : 'no_cards_client'.tr,
            fontSize: 13,
            color: Colors.grey,
            textAlign: TextAlign.center,
          ),
          if (isFiltered) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: onClearFilters,
              child: AppText(
                'clear_filters_client'.tr,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
