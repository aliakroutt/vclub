// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/LoyaltyProgramModel.dart' show ProgramMode;
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramsModel.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/ProgramModelDisplayExtension.dart';

/// Responsive sizing tokens. Percentages are computed against a clamped
/// baseline width so the UI doesn't keep scaling up forever on large
/// tablets, and content is capped to a comfortable reading width.
class _Dim {
  _Dim(Size raw)
      : w = raw.width.clamp(320, 520),
        h = raw.height.clamp(560, 900),
        contentMaxWidth = raw.width > 640 ? 560.0 : double.infinity;

  final double w;
  final double h;
  final double contentMaxWidth;

  double wp(double f) => w * f;
  double hp(double f) => h * f;
}

class ProgramDetailsScreen extends StatelessWidget {
  const ProgramDetailsScreen({super.key, required this.program});

  final ProgramModel program;

  static IconData _modeIcon(ProgramMode mode) => switch (mode) {
    ProgramMode.points => Iconsax.coin,
    ProgramMode.stamps => Iconsax.ticket_star,
    ProgramMode.cashback => Iconsax.money,
  };

  static String _modeKey(ProgramMode mode) => switch (mode) {
    ProgramMode.points => "program_mode_points",
    ProgramMode.stamps => "program_mode_stamps",
    ProgramMode.cashback => "program_mode_cashback",
  };

  static Color _modeColor(ProgramMode mode) => switch (mode) {
    ProgramMode.points => const Color(0xFF7C6FF7),
    ProgramMode.stamps => const Color(0xFFFFB930),
    ProgramMode.cashback => const Color(0xFF00C896),
  };

  String _fmtDate(DateTime? d) {
    if (d == null) return "—";
    const months = [
      "jan", "feb", "mar", "apr", "may", "jun",
      "jul", "aug", "sep", "oct", "nov", "dec"
    ];
    return "${d.day} ${"month_${months[d.month - 1]}_merchant".tr} ${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _modeColor(program.uiMode);
    final isActive = program.isActive;
    final statusColor = isActive ? const Color(0xFF00C896) : const Color(0xFFFF6B6B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E0E10) : const Color(0xFFF8F8FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final d = _Dim(Size(constraints.maxWidth, constraints.maxHeight));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TOP BAR ─────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: d.wp(.045),
                    vertical: d.hp(.012),
                  ),
                  child: FadeSlide(
                    delayMs: 200,
                    child: _circleButton(
                      context,
                      icon: Directionality.of(context) == TextDirection.rtl
                          ? Iconsax.arrow_right_3_copy
                          : Iconsax.arrow_left_2_copy,
                      onTap: () => Get.back(),
                    ),
                  ),
                ),

                // ── SCROLLABLE CONTENT ───────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: d.contentMaxWidth),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            d.wp(.045),
                            0,
                            d.wp(.045),
                            d.hp(.04),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeSlide(
                                delayMs: 250,
                                child: _HeroCard(
                                  program: program,
                                  color: color,
                                  icon: _modeIcon(program.uiMode),
                                  modeLabel: _modeKey(program.uiMode).tr,
                                  isActive: isActive,
                                  statusColor: statusColor,
                                  isDark: isDark,
                                  d: d,
                                ),
                              ),

                              SizedBox(height: d.hp(.024)),

                              FadeSlide(delayMs: 270, child: _SectionTitle(title: "program_config_merchant".tr, d: d)),
                              SizedBox(height: d.hp(.012)),
                              FadeSlide(delayMs: 290, child: _ConfigGrid(program: program, color: color, d: d, isDark: isDark)),

                              if (program.bonuses.isNotEmpty) ...[
                                SizedBox(height: d.hp(.028)),
                                FadeSlide(delayMs: 310, child: _SectionTitle(title: "program_bonuses_merchant".tr, d: d)),
                                SizedBox(height: d.hp(.012)),
                                FadeSlide(delayMs: 330, child: _BonusesList(program: program, color: color, d: d, isDark: isDark)),
                              ],

                              if (program.limits != null) ...[
                                SizedBox(height: d.hp(.028)),
                                FadeSlide(delayMs: 350, child: _SectionTitle(title: "program_limits_merchant".tr, d: d)),
                                SizedBox(height: d.hp(.012)),
                                FadeSlide(delayMs: 370, child: _LimitsGrid(program: program, color: color, d: d, isDark: isDark)),
                              ],

                              if (program.vipLevels.isNotEmpty) ...[
                                SizedBox(height: d.hp(.028)),
                                FadeSlide(delayMs: 390, child: _SectionTitle(title: "program_vip_levels_merchant".tr, d: d)),
                                SizedBox(height: d.hp(.012)),
                                FadeSlide(delayMs: 410, child: _VipLevelsList(program: program, d: d, isDark: isDark)),
                              ],

                              SizedBox(height: d.hp(.028)),
                              FadeSlide(delayMs: 430, child: _SectionTitle(title: "program_review_reward_merchant".tr, d: d)),
                              SizedBox(height: d.hp(.012)),
                              FadeSlide(delayMs: 450, child: _ReviewRewardCard(program: program, d: d, isDark: isDark)),

                              if (program.joinUrl != null) ...[
                                SizedBox(height: d.hp(.028)),
                                FadeSlide(delayMs: 470, child: _SectionTitle(title: "program_join_link_merchant".tr, d: d)),
                                SizedBox(height: d.hp(.012)),
                                FadeSlide(
                                  delayMs: 490,
                                  child: _JoinLinkCard(url: program.joinUrl!, color: color, d: d, isDark: isDark),
                                ),
                              ],

                              SizedBox(height: d.hp(.03)),
                              FadeSlide(
                                delayMs: 510,
                                child: _MetaFooter(
                                  createdAt: _fmtDate(program.createdAt),
                                  updatedAt: _fmtDate(program.updatedAt),
                                  d: d,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _circleButton(
  BuildContext context, {
  required IconData icon,
  required VoidCallback onTap,
}) {
  final isDark = Get.isDarkMode;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06),
        ),
      ),
      child: Icon(icon, size: 18),
    ),
  );
}

/// Shared flat, hairline-bordered surface used across every card in this
/// screen so the whole page reads as one consistent system.
class _FlatCard extends StatelessWidget {
  const _FlatCard({
    required this.child,
    required this.isDark,
    this.padding,
    this.radius = 18,
    this.tint,
  });

  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: tint != null
            ? tint!.withOpacity(isDark ? .10 : .07)
            : Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: tint != null
              ? tint!.withOpacity(.18)
              : (isDark ? Colors.white.withOpacity(.07) : Colors.black.withOpacity(.06)),
        ),
      ),
      child: child,
    );
  }
}

/// Minimal dot + label pill (used for status/mode/default tags).
class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.5, color: color),
            const SizedBox(width: 5),
          ] else ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 6),
          ],
          AppText(label, fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
        ],
      ),
    );
  }
}

// ── HERO CARD ─────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.program,
    required this.color,
    required this.icon,
    required this.modeLabel,
    required this.isActive,
    required this.statusColor,
    required this.isDark,
    required this.d,
  });

  final ProgramModel program;
  final Color color;
  final IconData icon;
  final String modeLabel;
  final bool isActive;
  final Color statusColor;
  final bool isDark;
  final _Dim d;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(d.wp(.05)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: color.withOpacity(isDark ? .10 : .07),
        border: Border.all(color: color.withOpacity(.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: color.withOpacity(.14),
                  border: Border.all(color: color.withOpacity(.24)),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: d.wp(.04)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      program.title,
                      fontSize: d.wp(.05),
                      fontWeight: FontWeight.w800,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: d.hp(.006)),
                    AppText(
                      "/${program.slug}",
                      fontSize: d.wp(.032),
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white.withOpacity(.4) : Colors.black.withOpacity(.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: d.hp(.018)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(icon: icon, label: modeLabel, color: color),
              _Pill(
                label: isActive ? "program_active".tr : "program_inactive".tr,
                color: statusColor,
              ),
              if (program.isDefault)
                _Pill(label: "program_default_merchant".tr, color: const Color(0xFFFFB930)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── SECTION TITLE ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.d});

  final String title;
  final _Dim d;

  @override
  Widget build(BuildContext context) {
    return AppText(title, fontSize: d.wp(.04), fontWeight: FontWeight.w800);
  }
}

// ── CONFIG GRID (mode-dependent) ─────────────────────────────────────────

class _ConfigGrid extends StatelessWidget {
  const _ConfigGrid({
    required this.program,
    required this.color,
    required this.d,
    required this.isDark,
  });

  final ProgramModel program;
  final Color color;
  final _Dim d;
  final bool isDark;

  List<Map<String, dynamic>> get _items {
    switch (program.uiMode) {
      case ProgramMode.points:
        return [
          {"icon": Iconsax.coin, "label": "pts_per_currency_merchant".tr, "value": _n(program.pointsPerCurrencyUnit)},
          {"icon": Iconsax.gift, "label": "pts_per_reward_merchant".tr, "value": program.pointsPerReward?.toString() ?? "—"},
          {"icon": Iconsax.calendar, "label": "pts_expiry_merchant".tr, "value": "${program.pointsExpiryDays} ${"days_merchant".tr}"},
          {"icon": Iconsax.shopping_cart, "label": "min_purchase_merchant".tr, "value": _n(program.minPurchase)},
        ];
      case ProgramMode.stamps:
        return [
          {"icon": Iconsax.ticket_star, "label": "stamps_per_visit_merchant".tr, "value": program.stampsPerVisit.toString()},
          {"icon": Iconsax.gift, "label": "stamps_per_reward_merchant".tr, "value": program.stampsPerReward.toString()},
          {"icon": Iconsax.calendar, "label": "stamps_expiry_merchant".tr, "value": "${program.stampsExpiryDays} ${"days_merchant".tr}"},
          {"icon": Iconsax.shopping_cart, "label": "min_purchase_merchant".tr, "value": _n(program.minPurchase)},
        ];
      case ProgramMode.cashback:
        return [
          {"icon": Iconsax.money, "label": "cashback_percent_merchant".tr, "value": "${_n(program.cashbackPercent)}%"},
          {"icon": Iconsax.shopping_cart, "label": "min_purchase_merchant".tr, "value": _n(program.cashbackMinPurchase)},
          {"icon": Iconsax.calendar, "label": "cashback_expiry_merchant".tr, "value": "${program.cashbackExpiryDays} ${"days_merchant".tr}"},
          {"icon": Iconsax.crown, "label": "vip_threshold_merchant".tr, "value": program.vipThreshold.toString()},
        ];
    }
  }

  String _n(num v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 460 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: d.wp(.03),
            mainAxisSpacing: d.wp(.03),
            childAspectRatio: crossAxisCount == 3 ? 1.5 : 2.4,
          ),
          itemBuilder: (context, i) {
            final item = items[i];
            return _FlatCard(
              isDark: isDark,
              padding: EdgeInsets.all(d.wp(.032)),
              radius: 16,
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(item["icon"] as IconData, color: color, size: 16),
                  ),
                  SizedBox(width: d.wp(.026)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          item["value"].toString(),
                          fontSize: d.wp(.036),
                          fontWeight: FontWeight.w800,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        AppText(
                          item["label"].toString(),
                          fontSize: d.wp(.026),
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white.withOpacity(.4) : Colors.black.withOpacity(.42),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── BONUSES LIST ──────────────────────────────────────────────────────────

class _BonusesList extends StatelessWidget {
  const _BonusesList({
    required this.program,
    required this.color,
    required this.d,
    required this.isDark,
  });

  final ProgramModel program;
  final Color color;
  final _Dim d;
  final bool isDark;

  IconData _bonusIcon(String type) => switch (type) {
    'birthday' => Iconsax.cake,
    'first_purchase' => Iconsax.shopping_bag,
    'multiplier' => Iconsax.flash_1,
    _ => Iconsax.gift,
  };

  String _bonusLabel(String type) => switch (type) {
    'birthday' => "bonus_birthday_merchant".tr,
    'first_purchase' => "bonus_first_purchase_merchant".tr,
    'multiplier' => "bonus_multiplier_merchant".tr,
    _ => type,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: program.bonuses.map((bonus) {
        final enabled = bonus.enabled;
        final tint = enabled ? color : Colors.grey;
        return Padding(
          padding: EdgeInsets.only(bottom: d.hp(.012)),
          child: _FlatCard(
            isDark: isDark,
            padding: EdgeInsets.symmetric(horizontal: d.wp(.035), vertical: d.hp(.014)),
            radius: 16,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tint.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_bonusIcon(bonus.type), color: tint, size: 18),
                ),
                SizedBox(width: d.wp(.035)),
                Expanded(
                  child: AppText(_bonusLabel(bonus.type), fontWeight: FontWeight.w700, fontSize: d.wp(.034)),
                ),
                AppText(
                  "+${bonus.value % 1 == 0 ? bonus.value.toStringAsFixed(0) : bonus.value.toStringAsFixed(1)}",
                  fontWeight: FontWeight.w800,
                  fontSize: d.wp(.036),
                  color: tint,
                ),
                SizedBox(width: d.wp(.025)),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled ? const Color(0xFF00C896) : Colors.grey.withOpacity(.5),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── LIMITS GRID ───────────────────────────────────────────────────────────

class _LimitsGrid extends StatelessWidget {
  const _LimitsGrid({
    required this.program,
    required this.color,
    required this.d,
    required this.isDark,
  });

  final ProgramModel program;
  final Color color;
  final _Dim d;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l = program.limits!;
    final items = [
      {"label": "limit_max_points_day_merchant".tr, "value": l.maxPointsPerDay},
      {"label": "limit_max_points_tx_merchant".tr, "value": l.maxPointsPerTx},
      {"label": "limit_max_rewards_month_merchant".tr, "value": l.maxRewardsPerMonth},
      {"label": "limit_max_stamps_day_merchant".tr, "value": l.maxStampsPerDay},
    ];

    return _FlatCard(
      isDark: isDark,
      padding: EdgeInsets.all(d.wp(.04)),
      child: Column(
        children: items.map((item) {
          final isLast = item == items.last;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : d.hp(.014)),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    item["label"].toString(),
                    fontSize: d.wp(.033),
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white.withOpacity(.55) : Colors.black.withOpacity(.55),
                  ),
                ),
                AppText("${item["value"]}", fontSize: d.wp(.036), fontWeight: FontWeight.w800, color: color),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── VIP LEVELS ────────────────────────────────────────────────────────────

class _VipLevelsList extends StatelessWidget {
  const _VipLevelsList({required this.program, required this.d, required this.isDark});

  final ProgramModel program;
  final _Dim d;
  final bool isDark;

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  String _ordinal(int i) {
    const numerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'];
    return i < numerals.length ? numerals[i] : '${i + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final maxPoints = program.vipLevels
        .map((l) => l.minPoints)
        .fold<int>(0, (a, b) => b > a ? b : a);

    final dimColor = isDark ? Colors.white.withOpacity(.48) : Colors.black.withOpacity(.48);

    return SizedBox(
      height: d.hp(.17).clamp(132, 156),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: program.vipLevels.length,
        separatorBuilder: (_, __) => SizedBox(width: d.wp(.03)),
        itemBuilder: (context, i) {
          final level = program.vipLevels[i];
          final color = _parseColor(level.color);
          final progress = maxPoints == 0
              ? 1.0
              : (level.minPoints / maxPoints).clamp(.08, 1.0);

          return Container(
            width: d.wp(.4).clamp(172, 212),
            padding: EdgeInsets.all(d.wp(.036)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: color.withOpacity(isDark ? .09 : .06),
              border: Border.all(color: color.withOpacity(.20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(.14),
                        border: Border.all(color: color.withOpacity(.32)),
                      ),
                      child: AppText(
                        _ordinal(i),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Icon(Iconsax.crown, size: 16, color: color.withOpacity(.55)),
                  ],
                ),
                SizedBox(height: d.hp(.016)),
                AppText(
                  level.name,
                  fontWeight: FontWeight.w800,
                  fontSize: d.wp(.037),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: d.hp(.003)),
                AppText(
                  "${level.minPoints}+ ${"pts_merchant".tr}",
                  fontSize: d.wp(.027),
                  fontWeight: FontWeight.w600,
                  color: dimColor,
                ),
                SizedBox(height: d.hp(.014)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 4,
                    child: Stack(
                      children: [
                        Container(color: color.withOpacity(.14)),
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(color: color),
                        ),
                      ],
                    ),
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

// ── REVIEW REWARD ─────────────────────────────────────────────────────────

class _ReviewRewardCard extends StatelessWidget {
  const _ReviewRewardCard({required this.program, required this.d, required this.isDark});

  final ProgramModel program;
  final _Dim d;
  final bool isDark;

  String _triggerLabel(String? trigger) => switch (trigger) {
    'reward_redeem' => "review_trigger_redeem_merchant".tr,
    'program_end' => "review_trigger_end_merchant".tr,
    _ => trigger ?? "—",
  };

  @override
  Widget build(BuildContext context) {
    return _FlatCard(
      isDark: isDark,
      padding: EdgeInsets.all(d.wp(.04)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB930).withOpacity(.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Iconsax.star_1, color: Color(0xFFFFB930), size: 20),
          ),
          SizedBox(width: d.wp(.035)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  "${program.reviewRewardPoints} ${"pts_merchant".tr} • ${_triggerLabel(program.reviewTrigger)}",
                  fontWeight: FontWeight.w700,
                  fontSize: d.wp(.034),
                ),
                SizedBox(height: d.hp(.004)),
                AppText(
                  "${program.reviewRewardCooldownDays} ${"days_cooldown_merchant".tr}",
                  fontSize: d.wp(.03),
                  color: isDark ? Colors.white.withOpacity(.42) : Colors.black.withOpacity(.42),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── JOIN LINK ─────────────────────────────────────────────────────────────

class _JoinLinkCard extends StatelessWidget {
  const _JoinLinkCard({required this.url, required this.color, required this.d, required this.isDark});

  final String url;
  final Color color;
  final _Dim d;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _FlatCard(
      isDark: isDark,
      tint: color,
      radius: 16,
      padding: EdgeInsets.all(d.wp(.035)),
      child: Row(
        children: [
          Icon(Iconsax.link, color: color, size: 18),
          SizedBox(width: d.wp(.025)),
          Expanded(
            child: AppText(
              url,
              fontSize: d.wp(.03),
              fontWeight: FontWeight.w600,
              color: color,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: url));
              AppSnackBar.success("link_copied_merchant".tr);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Iconsax.copy, size: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── META FOOTER ───────────────────────────────────────────────────────────

class _MetaFooter extends StatelessWidget {
  const _MetaFooter({required this.createdAt, required this.updatedAt, required this.d, required this.isDark});

  final String createdAt;
  final String updatedAt;
  final _Dim d;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final dim = isDark ? Colors.white.withOpacity(.32) : Colors.black.withOpacity(.32);
    return Column(
      children: [
        AppText(
          "${"program_created_merchant".tr}: $createdAt",
          fontSize: d.wp(.028),
          fontWeight: FontWeight.w600,
          color: dim,
        ),
        SizedBox(height: d.hp(.004)),
        AppText(
          "${"program_updated_merchant".tr}: $updatedAt",
          fontSize: d.wp(.028),
          fontWeight: FontWeight.w600,
          color: dim,
        ),
      ],
    );
  }
}