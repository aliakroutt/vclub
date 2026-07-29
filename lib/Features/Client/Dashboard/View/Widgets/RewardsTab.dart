import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Dashboard/Models/Client_Reward_Model.dart';
import 'package:vclub/Features/Client/Dashboard/Models/Client_wheel_history.dart';

class RewardsTab extends StatelessWidget {
  const RewardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientDashboardController>();
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final isRTL = Get.locale?.languageCode == 'ar';

    // Fetch wheel history once, lazily, without depending on State lifecycle.
    if (controller.wheel_history.isEmpty && !controller.wheelhistoryLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchWheelHistory();
      });
    }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
            AppText(
                  'rewards',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
            SizedBox(height: size.height * 0.018),
            _PremiumTabBar(
              selectedIndex: controller.rewardsSelectedTab,
              size: size,
              tabs: [
                _TabItem(icon: Iconsax.gift, label: 'programs_client'.tr),
                _TabItem(icon: Iconsax.reserve_copy, label: 'fortune_wheel_client'.tr),
              ],
            ),
            SizedBox(height: size.height * 0.018),
            Obx(() {
              return controller.rewardsSelectedTab.value == 0
                  ? _ProgramsList(controller: controller, size: size)
                  : _FortuneWheelList(controller: controller, size: size);
            }),
          ],
        ),
      ),
    );
  }
}

/// ==================== TAB ITEM MODEL ====================
class _TabItem {
  final IconData icon;
  final String label;
  _TabItem({required this.icon, required this.label});
}

/// ==================== PREMIUM SLIDING TAB BAR ====================
class _PremiumTabBar extends StatelessWidget {
  final RxInt selectedIndex;
  final List<_TabItem> tabs;
  final Size size;

  const _PremiumTabBar({
    required this.selectedIndex,
    required this.tabs,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: double.infinity,
        height: size.height * 0.056,
        padding: EdgeInsets.all(size.width * 0.01),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.08),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.10),
          ),
        ),
        child: Obx(() {
          final currentIndex = selectedIndex.value;

          return LayoutBuilder(
            builder: (context, constraints) {
              final segmentWidth = constraints.maxWidth / tabs.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: currentIndex * segmentWidth,
                    top: 0,
                    bottom: 0,
                    width: segmentWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      children: List.generate(tabs.length, (index) {
                        final active = currentIndex == index;
                        return Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => selectedIndex.value = index,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    tabs[index].icon,
                                    size: size.width * 0.042,
                                    color: active
                                        ? Colors.white
                                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                  ),
                                  SizedBox(width: size.width * 0.016),
                                  Directionality(
                                    textDirection: Get.locale?.languageCode == 'ar'
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: AppText(
                                      tabs[index].label,
                                      fontSize: size.width * 0.032,
                                      fontWeight: FontWeight.w700,
                                      color: active
                                          ? Colors.white
                                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}

/// ==================== PROGRAMS (rewards) LIST ====================
class _ProgramsList extends StatelessWidget {
  final ClientDashboardController controller;
  final Size size;

  const _ProgramsList({required this.controller, required this.size});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.rewardsLoading.value && controller.rewards.isEmpty) {
        return SizedBox(
          height: size.height * 0.22,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.rewardsError.value.isNotEmpty && controller.rewards.isEmpty) {
        return Center(
          child: _EmptyState(
            icon: Iconsax.warning_2,
            message: controller.rewardsError.value,
            size: size,
          ),
        );
      }

      final rewards = controller.rewards.cast<RewardModel>();

      if (rewards.isEmpty) {
        return Center(
          child: _EmptyState(
            icon: Iconsax.gift,
            message: 'no_rewards_client'.tr,
            size: size,
          ),
        );
      }

      return _SectionList(
        size: size,
        title: 'available_rewards_client'.trParams({'count': rewards.length.toString()}),
        totalCount: rewards.length,
        previewItemBuilder: (_, index) => RewardCard(reward: rewards[index]),
        fullItemBuilder: (_, index) => RewardCard(reward: rewards[index]),
        sheetTitle: 'available_rewards_client'.trParams({'count': rewards.length.toString()}),
      );
    });
  }
}

/// ==================== FORTUNE WHEEL LIST ====================
class _FortuneWheelList extends StatelessWidget {
  final ClientDashboardController controller;
  final Size size;

  const _FortuneWheelList({required this.controller, required this.size});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.wheelhistoryLoading.value && controller.wheel_history.isEmpty) {
        return SizedBox(
          height: size.height * 0.22,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.wheelhistoryError.value.isNotEmpty && controller.wheel_history.isEmpty) {
        return Center(
          child: _EmptyState(
            icon: Iconsax.warning_2,
            message: controller.wheelhistoryError.value.tr,
            size: size,
          ),
        );
      }

      final spins = controller.wheel_history;

      if (spins.isEmpty) {
        return Center(
          child: _EmptyState(
            icon: Iconsax.reserve_copy,
            message: 'no_wheel_history_client'.tr,
            size: size,
          ),
        );
      }

      return _SectionList(
        size: size,
        title: 'wheel_spins_count_client'.trParams({'count': spins.length.toString()}),
        totalCount: spins.length,
        previewItemBuilder: (_, index) => WheelHistoryCard(spin: spins[index]),
        fullItemBuilder: (_, index) => WheelHistoryCard(spin: spins[index]),
        sheetTitle: 'wheel_spins_count_client'.trParams({'count': spins.length.toString()}),
      );
    });
  }
}

/// ==================== SECTION LIST (no wrapper card — lives inside parent card) ====================
/// Shows a small heading, the first 3 items, and a "View All" button that
/// opens a bottom sheet with the complete list.
class _SectionList extends StatelessWidget {
  final Size size;
  final String title;
  final int totalCount;
  final Widget Function(BuildContext, int) previewItemBuilder;
  final Widget Function(BuildContext, int) fullItemBuilder;
  final String sheetTitle;

  static const int _previewCount = 3;

  const _SectionList({
    required this.size,
    required this.title,
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
        AppText(
          title,
          fontSize: size.width * 0.032,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
        SizedBox(height: size.height * 0.012),
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
      builder: (_) => _FullListSheet(
        size: size,
        title: sheetTitle,
        itemCount: totalCount,
        itemBuilder: fullItemBuilder,
      ),
    );
  }
}

/// ==================== VIEW ALL BUTTON ====================
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
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
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

/// ==================== FULL LIST BOTTOM SHEET ====================
class _FullListSheet extends StatelessWidget {
  final Size size;
  final String title;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _FullListSheet({
    required this.size,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: DraggableScrollableSheet(
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
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.008,
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
      ),
    );
  }
}

/// ==================== SHARED EMPTY STATE ====================
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Size size;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: size.width * 0.12, color: Colors.grey.shade400),
          SizedBox(height: size.height * 0.015),
          AppText(
            message,
            fontSize: size.width * 0.034,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

/// ==================== WHEEL HISTORY CARD ====================
class WheelHistoryCard extends StatelessWidget {
  final WheelHistoryModel spin;

  const WheelHistoryCard({super.key, required this.spin});

  bool get _isPoints => spin.type.toLowerCase() == 'points';

  Color get _accentColor =>
      _isPoints ? const Color(0xFFF59E0B) : const Color(0xFFE91E63);

  IconData get _typeIcon =>
      _isPoints ? Iconsax.coin : Iconsax.ticket_discount;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final color = _accentColor;
    final localeCode = Get.locale?.languageCode ?? 'en';
    final formattedDate =
        DateFormat('dd MMM yyyy · HH:mm', localeCode).format(spin.spunAt.toLocal());

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.withOpacity(0.04),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.032,
            vertical: size.height * 0.012,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.grey.withOpacity(0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: size.width * 0.115,
                height: size.width * 0.115,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: color.withOpacity(isDark ? 0.20 : 0.12),
                ),
                clipBehavior: Clip.antiAlias,
                child: spin.company.logo.isNotEmpty
                    ? Image.network(
                        spin.company.logo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(_typeIcon, color: color, size: size.width * 0.05),
                      )
                    : Icon(_typeIcon, color: color, size: size.width * 0.05),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      spin.label,
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: size.height * 0.004),
                    AppText(
                      spin.company.name,
                      fontSize: size.width * 0.027,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: size.height * 0.003),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.calendar_1_copy,
                            size: size.width * 0.028, color: Colors.grey.shade400),
                        SizedBox(width: size.width * 0.01),
                        Flexible(
                          child: AppText(
                            formattedDate,
                            fontSize: size.width * 0.024,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade400,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: size.width * 0.02),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.026,
                  vertical: size.height * 0.007,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon, size: size.width * 0.032, color: Colors.white),
                    SizedBox(width: size.width * 0.012),
                    AppText(
                      _isPoints ? '+${spin.value}' : '${spin.value}%',
                      fontSize: size.width * 0.026,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

/// ==================== REWARD CARD ====================
class RewardCard extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback? onTap;

  const RewardCard({super.key, required this.reward, this.onTap});

  Color get _accentColor {
    switch (reward.reward.type.toLowerCase()) {
      case 'auto':
        return const Color(0xFF7C4DFF);
      case 'product':
        return const Color(0xFFFF7043);
      case 'service':
        return const Color(0xFF4D96FF);
      case 'voucher':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF26A69A);
    }
  }

  IconData get _typeIcon {
    switch (reward.reward.type.toLowerCase()) {
      case 'auto':
        return Iconsax.magic_star;
      case 'product':
        return Iconsax.reserve;
      case 'service':
        return Iconsax.activity;
      case 'voucher':
        return Iconsax.ticket_discount;
      default:
        return Iconsax.gift;
    }
  }

  bool get _isFulfilled {
    final s = reward.status.toLowerCase();
    return s == 'fulfilled' || s == 'redeemed' || s == 'validated' || s == 'completed';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'fulfilled':
      case 'redeemed':
      case 'validated':
      case 'completed':
        return const Color(0xFF16A34A);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'expired':
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'fulfilled':
      case 'redeemed':
      case 'validated':
      case 'completed':
        return Iconsax.tick_circle_copy;
      case 'pending':
        return Iconsax.clock;
      case 'expired':
      case 'cancelled':
      case 'rejected':
        return Iconsax.close_circle;
      default:
        return Iconsax.info_circle;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'fulfilled':
        return 'fulfilled_client'.tr;
      case 'redeemed':
        return 'redeemed_client'.tr;
      case 'validated':
        return 'validated_client'.tr;
      case 'pending':
        return 'pending_client'.tr;
      case 'expired':
        return 'expired_client'.tr;
      case 'cancelled':
        return 'cancelled_client'.tr;
      case 'rejected':
        return 'rejected_client'.tr;
      default:
        return status.isEmpty ? 'unknown_client'.tr : status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;

    final color = _accentColor;
    final statusColor = _statusColor(reward.status);
    final statusLower = reward.status.toLowerCase();
    final disabled = statusLower == 'expired' ||
        statusLower == 'cancelled' ||
        statusLower == 'rejected';
    final isAuto = reward.validatedBy == null;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.withOpacity(0.04),
          child: InkWell(
            onTap: onTap,
            splashColor: color.withOpacity(0.06),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.032,
                vertical: size.height * 0.012,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.grey.withOpacity(0.10),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: size.width * 0.115,
                    height: size.width * 0.115,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: color.withOpacity(isDark ? 0.20 : 0.12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: reward.company.logo.isNotEmpty
                        ? Image.network(
                            reward.company.logo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(_typeIcon, color: color, size: size.width * 0.05),
                          )
                        : Icon(_typeIcon, color: color, size: size.width * 0.05),
                  ),
                  SizedBox(width: size.width * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          reward.reward.name.isNotEmpty
                              ? reward.reward.name
                              : 'reward_client'.tr,
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: size.height * 0.004),
                        Row(
                          children: [
                            Flexible(
                              child: AppText(
                                reward.company.name,
                                fontSize: size.width * 0.027,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade500,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isAuto) ...[
                              SizedBox(width: size.width * 0.015),
                              _AutoTag(size: size, isDark: isDark),
                            ],
                          ],
                        ),
                        if (reward.redeemedAt != null) ...[
                          SizedBox(height: size.height * 0.003),
                          _DateRow(date: reward.redeemedAt!, size: size),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  _StatusBadge(
                    icon: _statusIcon(reward.status),
                    label: _statusLabel(reward.status),
                    color: statusColor,
                    size: size,
                    filled: _isFulfilled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill marking a reward as auto-validated (no manual validator).
class _AutoTag extends StatelessWidget {
  final Size size;
  final bool isDark;

  const _AutoTag({required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.016,
        vertical: size.height * 0.002,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.blueGrey.withOpacity(0.10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.flash_circle_copy, size: size.width * 0.022, color: Colors.blueGrey),
          SizedBox(width: size.width * 0.006),
          AppText(
            'auto_validated_client'.tr,
            fontSize: size.width * 0.021,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}

/// Small date/time row shown under the title. Locale-aware formatting.
class _DateRow extends StatelessWidget {
  final DateTime date;
  final Size size;

  const _DateRow({required this.date, required this.size});

  @override
  Widget build(BuildContext context) {
    final localeCode = Get.locale?.languageCode ?? 'en';
    final formatted =
        DateFormat('dd MMM yyyy · HH:mm', localeCode).format(date.toLocal());

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Iconsax.calendar_1_copy,
          size: size.width * 0.028,
          color: Colors.grey.shade400,
        ),
        SizedBox(width: size.width * 0.01),
        Flexible(
          child: AppText(
            formatted,
            fontSize: size.width * 0.024,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade400,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Status pill. Fulfilled/used gets a bolder, filled treatment.
class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Size size;
  final bool filled;

  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.026,
        vertical: size.height * 0.007,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: filled ? color : color.withOpacity(0.12),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size.width * 0.032, color: filled ? Colors.white : color),
          SizedBox(width: size.width * 0.012),
          AppText(
            label,
            fontSize: size.width * 0.026,
            fontWeight: FontWeight.w700,
            color: filled ? Colors.white : color,
          ),
        ],
      ),
    );
  }
}