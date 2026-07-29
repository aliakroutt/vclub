import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/MyCardsDash.dart';

Color loyaltyModeColor(String mode) {
  switch (mode) {
    case 'stamps':
      return const Color(0xFF29B6F6);
    case 'cashback':
      return const Color(0xFF4CAF50);
    case 'points':
    default:
      return const Color(0xFFFFB300);
  }
}

// ============================================================
// PANEL CONTAINER
// Rounded ONLY on top-left / top-right, fixed height, vertically
// scrollable content (Quick Actions + Stats). Drop this under the
// animated card header to get the "bottom sheet drawer" look.
// ============================================================
class LoyaltyCardDetailsPanel extends StatelessWidget {
  final ClientCardModel card;
  final VoidCallback? onGoogleWallet;
  final VoidCallback? onAppleWallet;

  /// Fixed height of the panel. Defaults to 58% of screen height.
  final double? height;

  const LoyaltyCardDetailsPanel({
    super.key,
    required this.card,
    this.onGoogleWallet,
    this.onAppleWallet,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = height ?? screenHeight * 0.46;

    return Container(
      height: panelHeight,
      width: double.infinity,
      // padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14161B) : const Color(0xFFF7F8FA),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Drag handle for the drawer feel.
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.18)
                  : Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                
                LoyaltyQuickActionsRow(
                  card: card,
                  onGoogleWallet: onGoogleWallet,
                  onAppleWallet: onAppleWallet,
                ),
                const SizedBox(height: 12),
                LoyaltyCardStatsSection(card: card),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// QUICK ACTIONS  (Show QR / Google Wallet / Apple Wallet)
// Vertical, premium, staggered fade-slide entrance.
// ============================================================
class LoyaltyQuickActionsRow extends StatelessWidget {
  final ClientCardModel card;
  final VoidCallback? onGoogleWallet;
  final VoidCallback? onAppleWallet;

  const LoyaltyQuickActionsRow({
    super.key,
    required this.card,
    this.onGoogleWallet,
    this.onAppleWallet,
  });

  @override
  Widget build(BuildContext context) {
    final accent = loyaltyModeColor(card.program.mode);
    final isDark = Get.find<ThemeService>().isDarkMode.value;

    final actions = <_ActionData>[
      _ActionData(
        icon: Iconsax.scan_barcode,
        label: 'show_qr_action_client'.tr,
        subtitle: 'show_qr_action_subtitle_client'.tr,
        gradient: [accent, accent.withOpacity(0.65)],
        onTap: () => showCardQrDialog(context, card: card),
      ),
      _ActionData(
        icon: Iconsax.google_copy,
        label: 'google_wallet_action_client'.tr,
        subtitle: 'google_wallet_action_subtitle_client'.tr,
        gradient: const [
          Color(0xFF5B8DEF), // Soft Google Blue
          Color(0xFFF0625D), // Soft Google Red
          Color(0xFFF6C445), // Soft Google Yellow
          Color(0xFF57BB6C), // Soft Google Green
        ],
        onTap: onGoogleWallet ?? () => _comingSoon(context),
      ),
      _ActionData(
        icon: Iconsax.apple,
        label: 'apple_wallet_action_client'.tr,
        subtitle: 'apple_wallet_action_subtitle_client'.tr,
        gradient: isDark
            ? const [Color(0xFF3A3A3C), Color(0xFF1C1C1E)]
            : const [Color(0xFF2C2C2E), Color(0xFF000000)],
        onTap: onAppleWallet ?? () => _comingSoon(context),
      ),
    ];

    return Column(
      children: List.generate(actions.length, (i) {
        final data = actions[i];
        return Padding(
          padding: EdgeInsets.only(bottom: i == actions.length - 1 ? 0 : 12),
          child: FadeSlide(
            delayMs: 150 + i * 200,
            child: _VerticalActionCard(data: data, isDark: isDark),
          ),
        );
      }),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText('coming_soon_client'.tr, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  _ActionData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
}

class _VerticalActionCard extends StatefulWidget {
  final _ActionData data;
  final bool isDark;

  const _VerticalActionCard({required this.data, required this.isDark});

  @override
  State<_VerticalActionCard> createState() => _VerticalActionCardState();
}

class _VerticalActionCardState extends State<_VerticalActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final data = widget.data;

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: data.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1F26) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.35)
                      : Colors.black.withOpacity(0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: data.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: data.gradient.first.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        data.label,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        data.subtitle,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.04),
                  ),
                  child: Icon(
                    Get.locale?.languageCode == 'ar'
                        ? Iconsax.arrow_circle_left_copy
                        : Iconsax.arrow_circle_right_copy,
                    size: 15,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CARD INFO / STATS SECTION  (depends on program.mode)
// Vertical premium list, staggered fade-slide entrance.
// ============================================================
class LoyaltyCardStatsSection extends StatelessWidget {
  final ClientCardModel card;
  const LoyaltyCardStatsSection({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final tiles = _tileDataForMode(card);

    return Column(
      children: List.generate(tiles.length, (i) {
        final t = tiles[i];
        return Padding(
          padding: EdgeInsets.only(bottom: i == tiles.length - 1 ? 0 : 10),
          child: FadeSlide(
            delayMs: 300 + (i+1) * 250,
            child: _VerticalStatTile(data: t, isDark: isDark),
          ),
        );
      }),
    );
  }

  List<_StatData> _tileDataForMode(ClientCardModel card) {
    final program = card.program;
    final accent = loyaltyModeColor(program.mode);
    final lastActivity = card.lastActivityAt != null
        ? DateFormat('dd/MM/yyyy').format(card.lastActivityAt!)
        : 'never_activity_client'.tr;

    final common = <_StatData>[
      _StatData(
        icon: Iconsax.crown_1,
        label: 'tier_label_client'.tr,
        value: card.tier.isEmpty ? '-' : card.tier,
        color: accent,
      ),
      _StatData(
        icon: Iconsax.repeat,
        label: 'visits_label_client'.tr,
        value: '${card.visits}',
        color: accent,
      ),
      _StatData(
        icon: Iconsax.calendar_1,
        label: 'last_activity_label_client'.tr,
        value: lastActivity,
        color: accent,
      ),
    ];

    switch (program.mode) {
      case 'stamps':
        return [
          _StatData(
            icon: Iconsax.award,
            label: 'stamps_per_reward_label_client'.tr,
            value: '${program.stampsPerReward}',
            color: accent,
          ),
          _StatData(
            icon: Iconsax.tick_circle,
            label: 'stamps_per_visit_label_client'.tr,
            value: '${program.stampsPerVisit}',
            color: accent,
          ),
          if (program.minPurchase > 0)
            _StatData(
              icon: Iconsax.shopping_cart,
              label: 'min_purchase_label_client'.tr,
              value: '${program.minPurchase}€',
              color: accent,
            ),
          ...common,
        ];

      case 'cashback':
        return [
          _StatData(
            icon: Iconsax.percentage_circle,
            label: 'cashback_percent_label_client'.tr,
            value: '${program.cashbackPercent}%',
            color: accent,
          ),
          if (program.cashbackMinPurchase > 0)
            _StatData(
              icon: Iconsax.shopping_cart,
              label: 'cashback_min_purchase_label_client'.tr,
              value: '${program.cashbackMinPurchase}€',
              color: accent,
            ),
          ...common,
        ];

      case 'points':
      default:
        return [
          _StatData(
            icon: Iconsax.star_1,
            label: 'points_per_reward_label_client'.tr,
            value: '${program.pointsPerReward}',
            color: accent,
          ),
          _StatData(
            icon: Iconsax.money_change,
            label: 'points_per_currency_label_client'.tr,
            value: '${program.pointsPerCurrencyUnit}',
            color: accent,
          ),
          if (program.minPurchase > 0)
            _StatData(
              icon: Iconsax.shopping_cart,
              label: 'min_purchase_label_client'.tr,
              value: '${program.minPurchase}€',
              color: accent,
            ),
          ...common,
        ];
    }
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  _StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _VerticalStatTile extends StatelessWidget {
  final _StatData data;
  final bool isDark;

  const _VerticalStatTile({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Accent bar for a premium, structured feel.
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.color.withOpacity(0.14),
            ),
            child: Icon(data.icon, size: 18, color: data.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: AppText(
              data.label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          AppText(
            data.value,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}