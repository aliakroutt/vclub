// my_cards_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/AppShimmer.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/MyCardsDash.dart';


// =========================
// SECTION — shadowed container: title + horizontal peek list
// =========================
class MyCardsSection extends StatelessWidget {
  const MyCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientDashboardController.to;
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final isRTL = Get.locale?.languageCode == 'ar';
    final size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(size.width * 0.036),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.30 : 0.06),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.08),
          ),
        ),
        child: Obx(() {
        final isLoading = controller.cardsLoading.value;
        final hasError = controller.cardsError.value.isNotEmpty;
        final cards = controller.cards;

        Widget body;

        if (isLoading && cards.isEmpty) {
          body = _PeekList(
            itemCount: 3,
            itemBuilder: (context, i) => _CompactShimmerCard(isDark: isDark),
          );
        } else if (hasError && cards.isEmpty) {
          body = _CompactErrorState(
            isDark: isDark,
            onRetry: () => controller.fetchCards(),
          );
        } else if (cards.isEmpty) {
          body = _CompactEmptyState(isDark: isDark);
        } else {
          body = _PeekList(
            itemCount: cards.length,
            itemBuilder: (context, i) => CompactLoyaltyCardView(
              card: cards[i],
              onTap: () => showCardQrDialog(context, card: cards[i]),
            ),
          );
        }

        return   Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               AppText(
                  'my_cards',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              
              const SizedBox(height: 12),
              body,
            ],
          
        );
      })),
    );
  }
}

/// Horizontal list showing the first card fully and a slice of the next.
class _PeekList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _PeekList({required this.itemCount, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.65;

    return SizedBox(
      height: 128,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        // padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itemCount,
        itemBuilder: (context, i) => Padding(
          padding: EdgeInsets.only(right: i == itemCount - 1 ? 0 : 10),
          child: SizedBox(width: cardWidth, child: itemBuilder(context, i)),
        ),
      ),
    );
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

// =========================
// COMPACT CARD
// =========================
class CompactLoyaltyCardView extends StatelessWidget {
  final ClientCardModel card;
  final VoidCallback onTap;
  final VoidCallback? onClaimReward;

  const CompactLoyaltyCardView({
    super.key,
    required this.card,
    required this.onTap,
    this.onClaimReward,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _metaForMode(card.program.mode);
    final accent = meta.color;
    final rewardReady = card.cardCompleted;
    bool _isRewardReady(ClientCardModel card) {
  switch (card.program.mode) {
    case 'points':
      return card.program.pointsPerReward > 0 &&
          card.points >= card.program.pointsPerReward;
    case 'stamps':
      return card.program.stampsPerReward > 0 &&
          card.stamps >= card.program.stampsPerReward;
    case 'cashback':
      // No reward-threshold field exists on ProgramModel for cashback
      // (cashbackMinPurchase is the earn-rate minimum, not a payout target).
      // Falling back to the server's cardCompleted flag here.
      return card.cardCompleted;
    default:
      return card.cardCompleted;
  }
}

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
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
              color: accent.withOpacity(0.16),
              blurRadius: 14,
              spreadRadius: -6,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -22,
              right: -18,
              child: _circle(accent.withOpacity(0.10), 68),
            ),
            Positioned(
              bottom: -30,
              left: -20,
              child: _circle(accent.withOpacity(0.06), 76),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CompactHeader(
                    card: card,
                    accent: accent,
                    icon: meta.icon,
                    rewardReady: _isRewardReady(card)
                  ),
                   Spacer(),
                  if (_isRewardReady(card))
                    _CompactClaimButton(
                          accent: accent,
                          card: card,
                          onTap: onClaimReward,
                        )
                    
                    
                  else ...[
                    _CompactBody(card: card, accent: accent),
                    
                  ],
                  Spacer(),
                  _CompactFooter(card: card, accent: accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(Color color, double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  final IconData icon;
  final bool rewardReady;

  const _CompactHeader({
    required this.card,
    required this.accent,
    required this.icon,
    required this.rewardReady,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent.withOpacity(0.18), accent.withOpacity(0.08)],
            ),
          ),
          child: card.company.logo.isEmpty
              ? Icon(icon, color: accent, size: 14)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    card.company.logo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(icon, color: accent, size: 14),
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                            ? child
                            : Icon(icon, color: accent, size: 14),
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                card.company.name,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppText(
                card.program.name,
                fontSize: 10,
                color: Colors.grey.withOpacity(0.8),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (rewardReady)
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: const Icon(Iconsax.gift, size: 11, color: Colors.white),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: accent.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.repeat, size: 9, color: accent),
                const SizedBox(width: 3),
                AppText(
                  '${card.visits}',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CompactBody extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _CompactBody({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    switch (card.program.mode) {
      case 'stamps':
        return _StampsRow(
          earned: card.stamps,
          target: card.program.stampsPerReward,
          accent: accent,
        );
      case 'cashback':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textBaseline: TextBaseline.alphabetic,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  LinearGradient(colors: [accent, accent.withOpacity(0.7)])
                      .createShader(bounds),
              child: AppText(
                '${card.cashbackBalance}€ ',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8,),
            AppText(
                '${card.program.cashbackPercent}% ${'cashback_earn_rate_client'.tr}',
                fontSize: 9.5,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              
            ),
          ],
        );
      case 'points':
      default:
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
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Flexible(
                  child: AppText(
                    target > 0
                        ? '/ $target ${'points_badge_client'.tr}'
                        : 'points_badge_client'.tr,
                    fontSize: 9.5,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 5,
                width: double.infinity,
                color: Colors.grey.withOpacity(0.3),
                child: FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent.withOpacity(0.7), accent],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}

/// Stamp dots that always fit on a single line, regardless of the
/// program's target count — dot size + spacing shrink to fit the
/// available width so every card keeps the same overall height.
class _StampsRow extends StatelessWidget {
  final int earned;
  final int target;
  final Color accent;

  const _StampsRow({
    required this.earned,
    required this.target,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final safeTarget = target > 0 ? target : 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        const maxDot = 16.0;
        const minDot = 8.0;
        const spacing = 4.0;

        double dot =
            (constraints.maxWidth - spacing * (safeTarget - 1)) / safeTarget;
        dot = dot.clamp(minDot, maxDot);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppText(
                  '$earned',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
                
                const SizedBox(width: 4),
                AppText(
                  '/$safeTarget',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                const SizedBox(width: 1),
                AppText(
                  'stamps',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
             Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(safeTarget, (i) {
                  final filled = i < earned;
                  return Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Container(
                      width: dot,
                      height: dot,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? accent : accent.withOpacity(0.14),
                        border: filled
                            ? null
                            : Border.all(color: accent.withOpacity(0.4), width: 1),
                      ),
                      child: filled && dot >= 12
                          ? Icon(Iconsax.award,
                              size: dot * 0.55, color: Colors.white)
                          : null,
                    ),
                  );
                }),
              
            ),
          ],
        );
      },
    );
  }
}

class _CompactFooter extends StatelessWidget {
  final ClientCardModel card;
  final Color accent;
  const _CompactFooter({required this.card, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: accent.withOpacity(0.12),
          ),
          child: AppText(
            card.tier.toUpperCase(),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
      ],
    );
  }
}

class _CompactClaimButton extends StatelessWidget {
  final Color accent;
  final ClientCardModel card;
  final VoidCallback? onTap;

  const _CompactClaimButton({
    required this.accent,
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap?.call();
          showLoyaltyRewardQrDialog(context, card: card, accent: accent);
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [accent, Color.lerp(accent, Colors.white, 0.18)!],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.35),
                blurRadius: 10,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.gift_copy, size: 13, color: Colors.white),
              const SizedBox(width: 6),
              AppText(
                'claim_reward_client'.tr,
                fontSize: 11.5,
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

// =========================
// SHIMMER
// =========================
class _CompactShimmerCard extends StatelessWidget {
  final bool isDark;
  const _CompactShimmerCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      isDark: isDark,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ShimmerBlock(width: 28, height: 28, radius: 9, isDark: isDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBlock(width: 80, height: 10, isDark: isDark),
                      const SizedBox(height: 5),
                      ShimmerBlock(width: 50, height: 8, isDark: isDark),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ShimmerBlock(width: 70, height: 16, isDark: isDark),
            const SizedBox(height: 7),
            ShimmerBlock(width: double.infinity, height: 5, radius: 20, isDark: isDark),
            const SizedBox(height: 10),
            ShimmerBlock(width: 40, height: 14, radius: 8, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// =========================
// ERROR / EMPTY STATES
// =========================
class _CompactErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;
  const _CompactErrorState({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Icon(Iconsax.warning_2, color: Colors.redAccent, size: 22),
          const SizedBox(height: 6),
          AppText('failed_load_cards'.tr, fontSize: 12, fontWeight: FontWeight.w500),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onRetry,
            child: AppText('retry'.tr, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CompactEmptyState extends StatelessWidget {
  final bool isDark;
  const _CompactEmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16 , vertical: 16),
      child: Center(
        child: Column(
          children: [
            Icon(Iconsax.card, color: isDark ? Colors.white38 : Colors.black26, size: 24),
            const SizedBox(height: 6),
            AppText('no_cards_client'.tr, fontSize: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}