import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vclub/API/Socket/Models/ScanRewardValidatedEvent.dart';
import 'package:vclub/API/SocketService.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Dashboard/Models/Client_Reward_Model.dart';
import 'package:vclub/Features/Client/Dashboard/Models/Client_wheel_history.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/WheelHistoryDetailDialog.dart';

class RewardsTab extends StatelessWidget {
  const RewardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientDashboardController>();
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final isRTL = Get.locale?.languageCode == 'ar';

    // Fetch wheel history once, lazily, without depending on State lifecycle.
    if (controller.wheel_history.isEmpty &&
        !controller.wheelhistoryLoading.value) {
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
            AppText('rewards', fontSize: 15, fontWeight: FontWeight.w700),
            SizedBox(height: size.height * 0.018),
            _PremiumTabBar(
              selectedIndex: controller.rewardsSelectedTab,
              size: size,
              tabs: [
                _TabItem(icon: Iconsax.gift, label: 'programs_client'.tr),
                _TabItem(
                  icon: Iconsax.reserve_copy,
                  label: 'fortune_wheel_client'.tr,
                ),
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
                                        : (isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600),
                                  ),
                                  SizedBox(width: size.width * 0.016),
                                  Directionality(
                                    textDirection:
                                        Get.locale?.languageCode == 'ar'
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: AppText(
                                      tabs[index].label,
                                      fontSize: size.width * 0.032,
                                      fontWeight: FontWeight.w700,
                                      color: active
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600),
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

      if (controller.rewardsError.value.isNotEmpty &&
          controller.rewards.isEmpty) {
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
        title: 'available_rewards_client'.trParams({
          'count': rewards.length.toString(),
        }),
        totalCount: rewards.length,
        previewItemBuilder: (_, index) => RewardCard(reward: rewards[index]),
        fullItemBuilder: (_, index) => RewardCard(reward: rewards[index]),
        sheetTitle: 'available_rewards_client'.trParams({
          'count': rewards.length.toString(),
        }),
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
      if (controller.wheelhistoryLoading.value &&
          controller.wheel_history.isEmpty) {
        return SizedBox(
          height: size.height * 0.22,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.wheelhistoryError.value.isNotEmpty &&
          controller.wheel_history.isEmpty) {
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
        title: 'wheel_spins_count_client'.trParams({
          'count': spins.length.toString(),
        }),
        totalCount: spins.length,
        previewItemBuilder: (_, index) => WheelHistoryCard(spin: spins[index]),
        fullItemBuilder: (_, index) => WheelHistoryCard(spin: spins[index]),
        sheetTitle: 'wheel_spins_count_client'.trParams({
          'count': spins.length.toString(),
        }),
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
    final visibleCount = totalCount < _previewCount
        ? totalCount
        : _previewCount;
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

  const _ViewAllButton({
    required this.size,
    required this.label,
    required this.onTap,
  });

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
                isRTL
                    ? Iconsax.arrow_circle_left_copy
                    : Iconsax.arrow_circle_right_copy,
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
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
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
                      separatorBuilder: (_, __) =>
                          SizedBox(height: size.height * 0.01),
                      itemBuilder: itemBuilder,
                    ),
                  ),
                ],
              ),
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

  IconData get _typeIcon => _isPoints ? Iconsax.coin : Iconsax.ticket_discount;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final color = _accentColor;
    final localeCode = Get.locale?.languageCode ?? 'en';
    final formattedDate = DateFormat(
      'dd MMM yyyy · HH:mm',
      localeCode,
    ).format(spin.spunAt.toLocal());

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        // color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.withOpacity(0.04),
        child: InkWell(
          onTap: () => showWheelHistoryDetailDialog(
            context,
            label: spin.label,
            companyName: spin.company.name,
            type: spin.type,
            value: spin.value,
            spunAt: spin.spunAt,
            code: spin.code,
          ),
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
                          errorBuilder: (_, __, ___) => Icon(
                            _typeIcon,
                            color: color,
                            size: size.width * 0.05,
                          ),
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
                          Icon(
                            Iconsax.calendar_1_copy,
                            size: size.width * 0.028,
                            color: Colors.grey.shade400,
                          ),
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
                      Icon(
                        _typeIcon,
                        size: size.width * 0.032,
                        color: Colors.white,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;

    final color = _accentColor;
    final statusLower = reward.status.toLowerCase();
    final disabled =
        statusLower == 'expired' ||
        statusLower == 'cancelled' ||
        statusLower == 'rejected';

    final isValidated = reward.validatedBy != null;
    // Locked = not yet validated (still needs to be scanned/claimed)
    final isLocked = !isValidated;

    final mutedGrey = isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.grey.withOpacity(0.04),
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
                // Locked rewards stay neutral/muted, unlocked (validated) get the accent tint
                color: isLocked
                    ? null
                    : color.withOpacity(isDark ? 0.09 : 0.05),
                border: Border.all(
                  color: isLocked
                      ? (isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.grey.withOpacity(0.10))
                      : color.withOpacity(0.35),
                  width: isLocked ? 1 : 1.3,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: size.width * 0.115,
                    height: size.width * 0.115,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isLocked
                          ? mutedGrey.withOpacity(isDark ? 0.15 : 0.12)
                          : color.withOpacity(isDark ? 0.20 : 0.12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: reward.company.logo.isNotEmpty
                        ? Image.network(
                            reward.company.logo,
                            fit: BoxFit.cover,
                            color: isLocked ? mutedGrey : null,
                            colorBlendMode: isLocked
                                ? BlendMode.saturation
                                : null,
                            errorBuilder: (_, __, ___) => Icon(
                              _typeIcon,
                              color: isLocked ? mutedGrey : color,
                              size: size.width * 0.05,
                            ),
                          )
                        : Icon(
                            _typeIcon,
                            color: isLocked ? mutedGrey : color,
                            size: size.width * 0.05,
                          ),
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
                          color: isLocked ? mutedGrey : null,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: size.height * 0.004),
                        AppText(
                          reward.company.name,
                          fontSize: size.width * 0.027,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (reward.redeemedAt != null) ...[
                          SizedBox(height: size.height * 0.003),
                          _DateRow(date: reward.redeemedAt!, size: size),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  if (isValidated)
                    _StatusBadge(
                      icon: Iconsax.tick_circle_copy,
                      label: 'validated_client'.tr,
                      color: const Color(0xFF16A34A),
                      size: size,
                    )
                  else
                    _LockIconButton(
                      color: mutedGrey,
                      size: size,
                      onTap: () => showDialog(
                        context: context,
                        barrierColor: Colors.black.withOpacity(0.5),
                        builder: (_) => _RewardCodeQrDialog(
                          code: reward.code,
                          accent: color,
                          companyId: reward.company.id,
                          rewardName: reward.reward.name,
                        ),
                      ),
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

/// Small date/time row shown under the title. Locale-aware formatting.
class _DateRow extends StatelessWidget {
  final DateTime date;
  final Size size;

  const _DateRow({required this.date, required this.size});

  @override
  Widget build(BuildContext context) {
    final localeCode = Get.locale?.languageCode ?? 'en';
    final formatted = DateFormat(
      'dd MMM yyyy · HH:mm',
      localeCode,
    ).format(date.toLocal());

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

  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.022,
        vertical: size.height * 0.006,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.14),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size.width * 0.032, color: color),
          SizedBox(width: size.width * 0.012),
          AppText(
            label,
            fontSize: size.width * 0.026,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _LockIconButton extends StatelessWidget {
  final Color color;
  final Size size;
  final VoidCallback onTap;

  const _LockIconButton({
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dim = size.width * 0.1;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: dim,
          height: dim,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.10),
            border: Border.all(color: color.withOpacity(0.3), width: 1.3),
          ),
          child: Icon(Iconsax.scan, color: color, size: dim * 0.46),
        ),
      ),
    );
  }
}

class _RewardCodeQrDialog extends StatefulWidget {
  final String code;
  final Color accent;
  final String? companyId;
  final String? rewardName;

  const _RewardCodeQrDialog({
    required this.code,
    required this.accent,
    this.companyId,
    this.rewardName,
  });

  @override
  State<_RewardCodeQrDialog> createState() => _RewardCodeQrDialogState();
}

class _RewardCodeQrDialogState extends State<_RewardCodeQrDialog> {
  StreamSubscription<Map<String, dynamic>>? _socketSub;
  bool _validated = false;
  ScanRewardValidatedEvent? _validatedEvent;

  @override
  void initState() {
    super.initState();
    _socketSub = SocketService.to.onRewardValidated.listen(_onRewardValidated);
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }

  void _onRewardValidated(Map<String, dynamic> data) {
    if (!mounted) return;

    final event = ScanRewardValidatedEvent.fromJson(data);

    // Match by code — the specific reward coupon this dialog shows.
    // If a companyId was passed in, also require it to match, as an
    // extra safety net against cross-company collisions.
    if (event.code != widget.code) return;
    if (widget.companyId != null && event.companyId != widget.companyId) return;

    setState(() {
      _validated = true;
      _validatedEvent = event;
    });

    // Refresh dashboard data (rewards list, cards, stats) in the background.
    ClientDashboardController.to.fetchRewards();
    ClientDashboardController.to.fetchHistory();
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final accent = widget.accent;
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
                        Iconsax.scan_barcode,
                        color: Colors.white,
                        size: size.width * 0.055,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: AppText(
                        'reward_code_title_client'.tr,
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
                child: _validated
                    ? _RewardValidatedSuccessState(
                        size: size,
                        accent: accent,
                        event: _validatedEvent!,
                        onClose: () => Navigator.of(context).pop(),
                      )
                    : Column(
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
                              data: widget.code,
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
                          SizedBox(height: size.height * 0.018),
                          // Code shown under the QR
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.height * 0.008,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.grey.withOpacity(0.08),
                            ),
                            child: AppText(
                              widget.code,
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
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

class _RewardValidatedSuccessState extends StatefulWidget {
  final Size size;
  final Color accent;
  final ScanRewardValidatedEvent event;
  final VoidCallback onClose;

  const _RewardValidatedSuccessState({
    required this.size,
    required this.accent,
    required this.event,
    required this.onClose,
  });

  @override
  State<_RewardValidatedSuccessState> createState() =>
      _RewardValidatedSuccessStateState();
}

class _RewardValidatedSuccessStateState
    extends State<_RewardValidatedSuccessState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _badgeScale;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _badgeScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
    ]).animate(_ctrl);

    _ringScale = Tween(begin: 0.6, end: 1.8).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    _ringOpacity = Tween(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );

    _fadeIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    _slideUp = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(_fadeIn);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final accent = widget.accent;
    final event = widget.event;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Animated badge with expanding ring pulse ──
        SizedBox(
          width: size.width * 0.32,
          height: size.width * 0.32,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: _ringOpacity.value,
                    child: Transform.scale(
                      scale: _ringScale.value,
                      child: Container(
                        width: size.width * 0.22,
                        height: size.width * 0.22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 2),
                        ),
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: _badgeScale.value,
                    child: Container(
                      width: size.width * 0.22,
                      height: size.width * 0.22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [accent, Color.lerp(accent, Colors.black, 0.2)!],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.45),
                            blurRadius: 24,
                            spreadRadius: -2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.medal_star_copy,
                        color: Colors.white,
                        size: size.width * 0.11,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        SizedBox(height: size.height * 0.02),

        FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  'reward_validated_title_client'.tr,
                  fontSize: size.width * 0.048,
                  fontWeight: FontWeight.w800,
                ),
                SizedBox(height: size.height * 0.016),

                // ── Reward name pill ──
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.014,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [accent.withOpacity(0.14), accent.withOpacity(0.05)],
                    ),
                    border: Border.all(color: accent.withOpacity(0.3), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.gift, color: accent, size: size.width * 0.05),
                      SizedBox(width: size.width * 0.02),
                      Flexible(
                        child: AppText(
                          event.rewardName,
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.014),
                AppText(
                  'reward_validated_subtitle_client'.tr,
                  fontSize: size.width * 0.034,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  textAlign: TextAlign.center,
                ),

                // ── Done button ──
                SizedBox(height: size.height * 0.026),
                _DoneButtonReward(accent: accent, onTap: widget.onClose, size: size),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DoneButtonReward extends StatelessWidget {
  final Color accent;
  final VoidCallback onTap;
  final Size size;

  const _DoneButtonReward({
    required this.accent,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [accent, Color.lerp(accent, Colors.black, 0.18)!],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.tick_square, size: size.width * 0.042, color: Colors.white),
              SizedBox(width: size.width * 0.02),
              AppText(
                'scan_done_client'.tr,
                fontSize: size.width * 0.038,
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

