import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Dashboard/Models/Client_History_Model.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/AppShimmer.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientDashboardController.to;
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'recent_activity_client'.tr,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),

          SizedBox(height: size.height * 0.018),

          Obx(() {
            final isLoading = controller.historyLoading.value;
            final hasError = controller.historyError.value.isNotEmpty;
            final items = controller.history;

            // ---------- LOADING ----------
            if (isLoading && items.isEmpty) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, __) =>
                    SizedBox(height: size.height * 0.01),
                itemBuilder: (context, i) =>
                    _ShimmerTransactionCard(isDark: isDark),
              );
            }

            // ---------- ERROR (no cached data) ----------
            if (hasError && items.isEmpty) {
              return _HistoryErrorState(
                isDark: isDark,
                onRetry: () => controller.fetchHistory(),
              );
            }

            // ---------- EMPTY ----------
            if (items.isEmpty) {
              return _HistoryEmptyState(isDark: isDark);
            }

            // ---------- LOADED ----------
            return _HistorySectionList(
              size: size,
              totalCount: items.length,
              previewItemBuilder: (_, index) =>
                  TransactionCard(transaction: items[index]),
              fullItemBuilder: (_, index) =>
                  TransactionCard(transaction: items[index]),
              sheetTitle: 'recent_activity_client'.tr,
            );
          }),
        ],
      ),
    );
  }
}

// =========================
// HELPERS
// =========================

/// Tries "history_action_<action>".tr first (e.g. history_action_add_points).
/// Falls back to a humanized version of the raw action string if no
/// translation is found, so you never show a raw i18n key to the user.
String _actionLabel(String action) {
  if (action.isEmpty) return '';
  final key = 'history_action_$action';
  final translated = key.tr;
  if (translated != key) return translated;

  return action
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// Real action values observed from the API: add_points, add_stamp, cashback,
/// review_reward, validate_reward, points_reward, stamp_reward.
/// Direction isn't reliable from the sign of `amount` alone (the API always
/// sends positive numbers, even for a reward that was *spent*), so it's
/// mapped explicitly per action instead.
const _earnActions = {'add_points', 'add_stamp', 'cashback', 'review_reward'};
const _spendActions = {'validate_reward'};
// points_reward / stamp_reward are informational log entries (a reward was
// claimed) that carry no amount — treated as neutral, not earn/spend.

bool? _directionFor(String action, int? amount) {
  if (_earnActions.contains(action)) return true;
  if (_spendActions.contains(action)) return false;
  if (amount == null) return null;
  return amount >= 0;
}

/// Reward claim/use entries shouldn't show a points-style badge at all —
/// it reads as noise next to "Reward used: jus gratuit".
const _noBadgeActions = {'validate_reward', 'points_reward', 'stamp_reward'};

class _BadgeInfo {
  final bool show;
  final String text;
  const _BadgeInfo({required this.show, this.text = ''});
}

/// Builds the badge text with the right unit per action type:
/// stamps get "stamp" appended, points get "pts" appended, cashback gets €.
_BadgeInfo _badgeFor(HistoryModel h, bool? isPositive) {
  final amount = h.amount;

  if (amount == null || _noBadgeActions.contains(h.action)) {
    return const _BadgeInfo(show: false);
  }

  final sign = isPositive == false ? '-' : '+';

  switch (h.action) {
    case 'add_stamp':
      return _BadgeInfo(
        show: true,
        text: '$sign$amount ${'stamps_badge_client'.tr}',
      );
    case 'add_points':
      return _BadgeInfo(
        show: true,
        text: '$sign$amount ${'points_badge_client'.tr}',
      );
    case 'cashback':
      return _BadgeInfo(show: true, text: '$sign$amount€');
    default:
      return _BadgeInfo(show: true, text: '$sign$amount');
  }
}

class _ActionMeta {
  final IconData icon;
  final Color color;
  const _ActionMeta(this.icon, this.color);
}

/// Distinct icon + accent color per action type, so a stamp, a cashback
/// credit, and a redeemed reward all look visually different at a glance —
/// not just "up" vs "down".
_ActionMeta _metaForAction(String action) {
  switch (action) {
    case 'add_points':
      return const _ActionMeta(Iconsax.star_1, Color(0xFFFFB300));
    case 'add_stamp':
      return const _ActionMeta(Iconsax.award, Color(0xFF29B6F6));
    case 'cashback':
      return const _ActionMeta(Iconsax.money_recive, Color(0xFF4CAF50));
    case 'validate_reward':
      return const _ActionMeta(Iconsax.ticket_star, Color(0xFFE91E63));
    case 'review_reward':
      return const _ActionMeta(Iconsax.medal_star, Color(0xFF6C63FF));
    case 'points_reward':
    case 'stamp_reward':
      return const _ActionMeta(Iconsax.gift, Color(0xFFAB47BC));
    default:
      return const _ActionMeta(Iconsax.activity, Colors.grey);
  }
}

/// Builds a richer description using `metadata` when available (e.g. the
/// reward's actual name) instead of just the generic action label.
String _descriptionFor(HistoryModel h) {
  final label = h.metadata?['label'] as String?;

  switch (h.action) {
    case 'validate_reward':
      return label != null
          ? "${'history_reward_used_client'.tr}: $label"
          : _actionLabel(h.action);

    case 'points_reward':
    case 'stamp_reward':
      return label != null
          ? "${'history_reward_claimed_client'.tr}: $label"
          : _actionLabel(h.action);

    case 'cashback':
      final percent = h.metadata?['cashbackPercent'];
      return percent != null
          ? "${_actionLabel(h.action)} ($percent%)"
          : _actionLabel(h.action);

    default:
      return _actionLabel(h.action);
  }
}

/// Deterministic accent color per company, so the same company always
/// gets the same avatar background even without a color field in the model.
Color _colorForCompany(String seed) {
  const palette = [
    Color(0xFFFFB300),
    Color(0xFF4D96FF),
    Color(0xFFE91E63),
    Color(0xFF00C48C),
    Color(0xFF6C63FF),
    Color(0xFFFF7043),
    Color(0xFF29B6F6),
  ];
  if (seed.isEmpty) return palette.first;
  final hash = seed.codeUnits.fold<int>(0, (a, b) => a + b);
  return palette[hash % palette.length];
}

String _formatDate(DateTime? date) {
  if (date == null) return '';
  final now = DateTime.now();
  final locale = Get.locale?.languageCode ?? 'en';
  final time =
      "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return "${'today_client'.tr} $time";
  }

  final weekday = DateFormat.E(locale).format(date); // localized short weekday
  return "$weekday $time";
}

// =========================
// SECTION LIST (preview + "View All" sheet, matches RewardsTab pattern)
// =========================
class _HistorySectionList extends StatelessWidget {
  final Size size;
  final int totalCount;
  final Widget Function(BuildContext, int) previewItemBuilder;
  final Widget Function(BuildContext, int) fullItemBuilder;
  final String sheetTitle;

  static const int _previewCount = 3;

  const _HistorySectionList({
    required this.size,
    required this.totalCount,
    required this.previewItemBuilder,
    required this.fullItemBuilder,
    required this.sheetTitle,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = totalCount < _previewCount ? totalCount : _previewCount;
    final hasMore = totalCount > _previewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleCount,
          separatorBuilder: (_, __) => SizedBox(height: size.height * 0.01),
          itemBuilder: previewItemBuilder,
        ),
        if (hasMore) ...[
          SizedBox(height: size.height * 0.016),
          _ViewAllButton(
            size: size,
            label: 'view_all_client'.tr,
            onTap: () => _openFullList(context),
          ),
        ],
      ],
    );
  }

  void _openFullList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistoryFullListSheet(
        size: size,
        title: sheetTitle,
        itemCount: totalCount,
        itemBuilder: fullItemBuilder,
      ),
    );
  }
}

// =========================
// VIEW ALL BUTTON
// =========================
class _ViewAllButton extends StatelessWidget {
  final Size size;
  final String label;
  final VoidCallback onTap;

  const _ViewAllButton({required this.size, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRTL = Get.locale?.languageCode == 'ar';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.013),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.primary.withOpacity(0.08),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
         
            children: [
              AppText(
                label,
                fontSize: size.width * 0.032,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
              SizedBox(width: size.width * 0.014),
              Icon(
                isRTL ? Iconsax.arrow_left_3 : Iconsax.arrow_right_3,
                size: size.width * 0.036,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// FULL LIST BOTTOM SHEET
// =========================
class _HistoryFullListSheet extends StatelessWidget {
  final Size size;
  final String title;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _HistoryFullListSheet({
    required this.size,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final isRTL = Get.locale?.languageCode == 'ar';

    return  DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.012),
                Container(
                  width: size.width * 0.1,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.016,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          title,
                          fontSize: size.width * 0.042,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Iconsax.close_circle),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      top: size.height * 0.008 ,
                      bottom: size.height * 0.15,
                      left: size.width * 0.05 ,
                      right: size.width * 0.05,
                      
                    ),
                    itemCount: itemCount,
                    separatorBuilder: (_, __) => SizedBox(height: size.height * 0.01),
                    itemBuilder: itemBuilder,
                  ),
                ),
              ],
            ),
          );
        },
      
    );
  }
}

// =========================
// TRANSACTION CARD (real data)
// =========================
class TransactionCard extends StatelessWidget {
  final HistoryModel transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final amount = transaction.amount;
    final isPositive = _directionFor(transaction.action, amount);
    final meta = _metaForAction(transaction.action);
    final badge = _badgeFor(transaction, isPositive);

    // Icon box always reflects the *type* of action (stamp, cashback, reward…).
    // The amount badge (if any) is colored by earn/spend direction.
    final badgeColor = isPositive == null
        ? Colors.grey
        : (isPositive ? Colors.green : Colors.red);
    final badgeBg = badgeColor.withOpacity(0.10);

    final companyColor = _colorForCompany(transaction.company.name);
    final date = DateTime.tryParse(transaction.createdAt);

    return Container(
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).cardColor,
        border: Border.all(color: meta.color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: size.width * 0.12,
            height: size.width * 0.12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: meta.color.withOpacity(0.12),
            ),
            child: Icon(
              meta.icon,
              color: meta.color,
              size: size.width * 0.055,
            ),
          ),

          SizedBox(width: size.width * 0.03),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CompanyAvatar(
                      logo: transaction.company.logo,
                      name: transaction.company.name,
                      color: companyColor,
                      size: size.width * 0.05,
                    ),
                    SizedBox(width: size.width * 0.015),
                    Flexible(
                      child: AppText(
                        transaction.company.name,
                        fontSize: size.width * 0.035,
                        fontWeight: FontWeight.w700,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.004),

                AppText(
                  _descriptionFor(transaction),
                  fontSize: size.width * 0.03,
                  color: Colors.grey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: size.height * 0.006),

                AppText(
                  _formatDate(date),
                  fontSize: size.width * 0.028,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          if (badge.show)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.008,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: badgeBg,
              ),
              child: AppText(
                badge.text,
                fontSize: size.width * 0.032,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  final String logo;
  final String name;
  final Color color;
  final double size;

  const _CompanyAvatar({
    required this.logo,
    required this.name,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: color.withOpacity(0.15),
        child: logo.isEmpty
            ? Center(
                child: AppText(
                  initial,
                  fontSize: size * 0.55,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              )
            : Image.network(
                logo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: AppText(
                    initial,
                    fontSize: size * 0.55,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.5,
                      height: size * 0.5,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: color,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// =========================
// SHIMMER PLACEHOLDER CARD
// =========================
class _ShimmerTransactionCard extends StatelessWidget {
  final bool isDark;
  const _ShimmerTransactionCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AppShimmer(
      isDark: isDark,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.035),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            ShimmerBlock(
              width: size.width * 0.12,
              height: size.width * 0.12,
              radius: 14,
              isDark: isDark,
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBlock(
                    width: size.width * 0.32,
                    height: 12,
                    isDark: isDark,
                  ),
                  SizedBox(height: size.height * 0.008),
                  ShimmerBlock(
                    width: size.width * 0.45,
                    height: 10,
                    isDark: isDark,
                  ),
                  SizedBox(height: size.height * 0.008),
                  ShimmerBlock(
                    width: size.width * 0.2,
                    height: 9,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            SizedBox(width: size.width * 0.02),
            ShimmerBlock(
              width: size.width * 0.12,
              height: size.height * 0.03,
              radius: 12,
              isDark: isDark,
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
class _HistoryErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _HistoryErrorState({required this.isDark, required this.onRetry});

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
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        children: [
          const Icon(Iconsax.warning_2, color: Colors.redAccent, size: 28),
          const SizedBox(height: 8),
          AppText(
            'failed_load_history'.tr,
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
// EMPTY STATE
// =========================
class _HistoryEmptyState extends StatelessWidget {
  final bool isDark;
  const _HistoryEmptyState({required this.isDark});

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
            Iconsax.receipt_2,
            color: isDark ? Colors.white38 : Colors.black26,
            size: 30,
          ),
          const SizedBox(height: 8),
          AppText(
            'no_history_client'.tr,
            fontSize: 13,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}