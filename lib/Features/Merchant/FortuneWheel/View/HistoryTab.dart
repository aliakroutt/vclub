import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelHistoryController.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Models/HistoryWheelModel.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/PremiumDatePicker.dart';

class HistoryTab extends StatelessWidget {
  HistoryTab({super.key});

  final controller = Get.put(FortuneWheelHistoryController());
  static const _accent = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.loading.value && !controller.initialLoaded.value) {
        return _buildSkeleton(context, isDark);
      }

      if (controller.error.value.isNotEmpty && controller.items.isEmpty) {
        return Center(child: _buildError(context));
      }

      return RefreshIndicator(
        color: _accent,
        onRefresh: controller.refresh,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _HistoryHeader(controller: controller, isDark: isDark, accent: _accent),
                  if (controller.hasFilters)
                    _FilterChipRow(controller: controller, isDark: isDark, accent: _accent),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            if (controller.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding:  EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.15),
                  child: _buildEmpty(context, controller.hasFilters),
                ),
              )
            else ...[
              SliverList(
                
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding:  EdgeInsets.only(bottom:  10),
                    child: _HistoryCard(item: controller.items[i], isDark: isDark),
                  ),
                  childCount: controller.items.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Obx(() => controller.loadingMore.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation(_accent),
                            ),
                          ),
                        ),
                      )
                    :  SizedBox(height: MediaQuery.of(context).size.height * 0.15)),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ── ERROR ──────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.warning_2, size: 40, color: Colors.redAccent),
            ),
            const SizedBox(height: 18),
            AppText("failed_load_history", fontSize: 15, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: controller.refresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.refresh, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    AppText("retry", fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── EMPTY ──────────────────────────────────────────────────────────────
  Widget _buildEmpty(BuildContext context, bool filtered) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : AppColors.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                filtered ? Iconsax.search_normal_1 : Iconsax.clock,
                size: 40,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.35),
              ),
            ),
            const SizedBox(height: 18),
            AppText(
              filtered ? "no_history_filtered_title" : "history_coming_soon_title",
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: AppText(
                filtered ? "no_history_filtered_subtitle" : "history_coming_soon_subtitle",
                fontSize: 13,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.55),
              ),
            ),
            if (filtered) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: controller.clearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.close_circle, size: 15, color: _accent),
                      const SizedBox(width: 6),
                      AppText("clear_filters", fontSize: 12.5, fontWeight: FontWeight.w700, color: _accent),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── SKELETON ───────────────────────────────────────────────────────────
  Widget _buildSkeleton(BuildContext context, bool isDark) {
    final base = isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.055);
    final highlight = isDark ? Colors.white.withOpacity(0.16) : Colors.black.withOpacity(0.11);
    final cardBorder = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);

    Widget block({double? width, required double height, double radius = 8}) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(radius)),
        );

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        period: const Duration(milliseconds: 1500),
        child: Column(
          children: [
            const SizedBox(height: 4),
            block(height: 64, radius: 18, width: double.infinity),
            const SizedBox(height: 14),
            ...List.generate(6, (i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  children: [
                    block(width: 44, height: 44, radius: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          block(width: 120, height: 13, radius: 5),
                          const SizedBox(height: 8),
                          block(width: 80, height: 10, radius: 5),
                        ],
                      ),
                    ),
                    block(width: 46, height: 30, radius: 8),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER ROW — spins count + start/end date icon buttons
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryHeader extends StatelessWidget {
  final FortuneWheelHistoryController controller;
  final bool isDark;
  final Color accent;

  const _HistoryHeader({required this.controller, required this.isDark, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Spins count
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: accent.withOpacity(0.10),
            ),
            child: Icon(Iconsax.chart_21, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "spins_count".trParams({'count': '${controller.totalCount.value}'}),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      "filter_by_date".tr,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.50),
                    ),
                  ],
                )),
          ),

          Obx(() => _DateIconButton(
                icon: Iconsax.calendar_1,
                active: controller.startDate.value != null,
                isDark: isDark,
                accent: accent,
                onTap: () async {
                  final result = await showPremiumDatePicker(
                    context,
                    isDark: isDark,
                    accent: accent,
                    initialDate: controller.startDate.value,
                    lastDate: controller.endDate.value ?? DateTime.now(),
                  );
                  if (result != null) controller.setStartDate(result);
                },
              )),
          const SizedBox(width: 8),
          Obx(() => _DateIconButton(
                icon: Iconsax.calendar_tick,
                active: controller.endDate.value != null,
                isDark: isDark,
                accent: accent,
                onTap: () async {
                  final result = await showPremiumDatePicker(
                    context,
                    isDark: isDark,
                    accent: accent,
                    initialDate: controller.endDate.value,
                    firstDate: controller.startDate.value,
                    lastDate: DateTime.now(),
                  );
                  if (result != null) controller.setEndDate(result);
                },
              )),
        ],
      ),
    );
  }
}

class _DateIconButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;

  const _DateIconButton({
    required this.icon,
    required this.active,
    required this.isDark,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: active
                  ? accent.withOpacity(0.14)
                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
              border: active ? Border.all(color: accent.withOpacity(0.35)) : null,
            ),
            child: Icon(
              icon,
              size: 18,
              color: active
                  ? accent
                  : (isDark ? Colors.white.withOpacity(0.45) : Colors.black.withOpacity(0.40)),
            ),
          ),
          if (active)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  border: Border.all(color: Theme.of(context).cardColor, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE FILTER CHIP ROW
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChipRow extends StatelessWidget {
  final FortuneWheelHistoryController controller;
  final bool isDark;
  final Color accent;

  const _FilterChipRow({required this.controller, required this.isDark, required this.accent});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Obx(() {
        final s = controller.startDate.value;
        final e = controller.endDate.value;
        String label;
        if (s != null && e != null) {
          label = '${_fmt(s)}  →  ${_fmt(e)}';
        } else if (s != null) {
          label = '${'start_date'.tr}: ${_fmt(s)}';
        } else {
          label = '${'end_date'.tr}: ${_fmt(e!)}';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: accent.withOpacity(isDark ? 0.12 : 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withOpacity(0.22)),
          ),
          child: Row(
            children: [
              Icon(Iconsax.calendar_1, size: 14, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: accent),
                ),
              ),
              GestureDetector(
                onTap: controller.clearFilters,
                child: Icon(Iconsax.close_circle, size: 16, color: accent.withOpacity(0.70)),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HISTORY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final WheelHistorySpinModel item;
  final bool isDark;

  const _HistoryCard({required this.item, required this.isDark});

  static const _palette = [
    Color(0xFF3B6D11), Color(0xFFE07B2E), Color(0xFF2E6BE0), Color(0xFFB02EE0),
    Color(0xFFE02E6B), Color(0xFF2EB0E0), Color(0xFF6E56CF),
  ];

  Color get _avatarColor => _palette[item.userName.hashCode.abs() % _palette.length];

  String get _initials {
    final parts = item.userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  IconData get _typeIcon {
    switch (item.type) {
      case 'discount': return Iconsax.discount_shape;
      case 'points': return Iconsax.star_1;
      case 'cashback': return Iconsax.wallet_money;
      case 'no_win': return Iconsax.close_circle;
      default: return Iconsax.gift;
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor;
    final date = item.createdAt.toLocal();
    final dateText = '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
    final timeText = '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.20 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, Color.lerp(color, Colors.black, 0.18)!],
              ),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.30), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + reward + code (if discount)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_typeIcon, size: 11, color: color),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.code != null && item.code!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.ticket, size: 10,
                          color: isDark ? Colors.white.withOpacity(0.35) : Colors.black.withOpacity(0.35)),
                      const SizedBox(width: 4),
                      Text(
                        item.code!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: isDark ? Colors.white.withOpacity(0.40) : Colors.black.withOpacity(0.40),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Date / time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateText,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white.withOpacity(0.65) : Colors.black.withOpacity(0.60),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white.withOpacity(0.35) : Colors.black.withOpacity(0.35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}