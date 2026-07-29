import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Client/MyQrCodes/Controllers/LoyaltyCardsController.dart';

class QrCodesScreen extends StatelessWidget {
  QrCodesScreen({super.key});

  final controller = Get.isRegistered<LoyaltyController>()
      ? Get.find<LoyaltyController>()
      : Get.put(LoyaltyController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          /// CARDS LIST — small, simple rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: controller.cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final card = controller.cards[index];
              return Obx(() {
                final isSelected = controller.selectedIndex.value == index;
                return _CardTile(
                  name: card.name,
                  type: card.type,
                  points: card.points,
                  icon: card.icon,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => controller.selectCard(index),
                );
              });
            },
          ),

          SizedBox(height: size.height * 0.025),

          /// DETAILS CARD
          Obx(() {
            final card = controller.cards[controller.selectedIndex.value];
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              child: _DetailsCard(
                key: ValueKey(card.id),
                card: card,
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// ---------------- SMALL LIST TILE ----------------
class _CardTile extends StatelessWidget {
  final String name;
  final String type;
  final int points;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CardTile({
    required this.name,
    required this.type,
    required this.points,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? AppColors.primary.withOpacity(isDark ? 0.16 : 0.08)
              : (isDark ? Colors.white.withOpacity(0.03) : Colors.white),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.primary.withOpacity(0.08),
            width: isSelected ? 1.3 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.10),
              ),
              child: Icon(
                icon,
                size: 17,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(name, fontWeight: FontWeight.w700, fontSize: 14),
                  const SizedBox(height: 2),
                  AppText(
                    "$type · $points pts",
                    fontSize: 11.5,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.55),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- DETAILS CARD ----------------
class _DetailsCard extends StatelessWidget {
  final dynamic card; // LoyaltyCardModel
  final bool isDark;

  const _DetailsCard({super.key, required this.card, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final progress = (card.points / card.targetPoints).clamp(0.0, 1.0);
    final remaining =
        (card.targetPoints - card.points).clamp(0, card.targetPoints) as num;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [AppColors.primary, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// TOP ROW: icon + name/type
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                ),
                child: Icon(card.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      card.name,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      card.type,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          /// BIG CENTERED QR PLACEHOLDER
          Center(
            child: Container(
              width: 168,
              height: 168,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Iconsax.scan_barcode,
                size: 110,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 26),

          /// POINTS ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AppText(
                "${card.points}",
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              AppText(
                "/ ${card.targetPoints} pts",
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.75),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// PROGRESS BAR
          Directionality(
            // textDirection: Directionality.of(context),
            textDirection: Get.locale?.languageCode == 'ar'  ? TextDirection.rtl : TextDirection.ltr ,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation(AppColors.primaryLight),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                "${(progress * 100).toStringAsFixed(0)}% complete",
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
              ),
              AppText(
                remaining > 0 ? "$remaining pts to go" : "Goal reached 🎉",
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ),

          const SizedBox(height: 22),

          /// WALLET BUTTONS
          Row(
            children: [
              Expanded(child: _walletButton(Iconsax.google, "Google Wallet")),
              const SizedBox(width: 10),
              Expanded(child: _walletButton(Iconsax.apple, "Apple Wallet")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletButton(IconData icon, String text) {
    return Material(
      color: Colors.white.withOpacity(0.14),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              AppText(
                text,
                fontSize: 12.5,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
