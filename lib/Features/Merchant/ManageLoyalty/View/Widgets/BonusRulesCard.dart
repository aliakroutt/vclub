import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/LoyaltyModeController.dart';

class BonusRulesCard extends StatelessWidget {
  BonusRulesCard({super.key});

  final controller = Get.find<LoyaltyModeController>();

  static const _accent = Color(0xFFE8640C);

 final eventTypes = [
  "birthday",
  "first_purchase",
  "multiplier",
  "referral",
];

  IconData _icon(String type) {
  switch (type) {
    case "birthday":
      return Iconsax.cake;
    case "first_purchase":
      return Iconsax.shopping_bag;
    case "multiplier":
      return Iconsax.activity;
    case "referral":
      return Iconsax.user_add;
    default:
      return Iconsax.gift;
  }
}

String _desc(String type) {
  switch (type) {
    case "birthday":
      return "birthday_desc".tr;
    case "first_purchase":
      return "first_purchase_desc".tr;
    case "multiplier":
      return "multiplier_desc".tr;
    case "referral":
      return "referral_desc".tr;
    default:
      return "";
  }
}

  

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * 0.045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
       color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── HEADER ──────────────────────────────────────────
          Row(
            children: [
              Container(
                width: size.width * 0.105,
                height: size.width * 0.105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _accent.withOpacity(0.10),
                ),
                child: Icon(
                  Iconsax.gift,
                  color: _accent,
                  size: size.width * 0.052,
                ),
              ),
              SizedBox(width: size.width * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "bonus_rules".tr,
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      "bonus_rules_subtitle".tr,
                      fontSize: size.width * 0.030,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.50),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.addRule("birthday"),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.add_circle, size: 15, color: _accent),
                      const SizedBox(width: 5),
                      AppText(
                        "add".tr,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.022),

          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),

          SizedBox(height: size.height * 0.018),

          /// ── RULES LIST ──────────────────────────────────────
          Obx(() {
            if (controller.bonusRules.isEmpty) {
              return _EmptyState(isDark: isDark, size: size);
            }

            return Column(
              children: List.generate(controller.bonusRules.length, (index) {
                final rule = controller.bonusRules[index];
                final isLast = index == controller.bonusRules.length - 1;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : size.height * 0.013,
                  ),
                  child: _RuleRow(
                    key: ValueKey('${rule.type}_$index'),
                    rule: rule,
                    index: index,
                    isDark: isDark,
                    size: size,
                    controller: controller,
                    eventTypes: eventTypes,
                    icon: _icon(rule.type),
                    desc: _desc(rule.type),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Single rule row
// ─────────────────────────────────────────────────────────────────────────────

class _RuleRow extends StatelessWidget {
  final BonusRule rule;
  final int index;
  final bool isDark;
  final Size size;
  final LoyaltyModeController controller;
  final List<String> eventTypes;
  final IconData icon;
  final String desc;

  static const _accent = Color(0xFFE8640C);

  const _RuleRow({
    super.key,
    required this.rule,
    required this.index,
    required this.isDark,
    required this.size,
    required this.controller,
    required this.eventTypes,
    required this.icon,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = rule.enabled
        ? _accent.withOpacity(0.30)
        : isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.06);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        border: Border.all(color: borderColor, width: rule.enabled ? 1.0 : 0.5),
      ),
      child: Column(
        children: [

          /// ── TOP STRIP: icon · dropdown · toggle ──────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.038,
              vertical: size.width * 0.026,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.025),
            ),
            child: Row(
              children: [
                /// icon badge
                Container(
                  width: size.width * 0.08,
                  height: size.width * 0.08,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _accent.withOpacity(0.10),
                  ),
                  child: Icon(icon, color: _accent, size: size.width * 0.038),
                ),
                SizedBox(width: size.width * 0.025),

                /// dropdown — now takes all remaining space
                Expanded(
                  child: Container(
                    height: 36,
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.028),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.04),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.07)
                            : Colors.black.withOpacity(0.06),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: rule.type,
                        isExpanded: true,
                        dropdownColor:
                            isDark ? const Color(0xFF1F1F23) : Colors.white,
                        icon: Icon(
                          Iconsax.arrow_down,
                          size: 13,
                          color: isDark
                              ? Colors.white.withOpacity(0.35)
                              : Colors.black.withOpacity(0.30),
                        ),
                        style: TextStyle(
                          fontSize: size.width * 0.032,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        items: eventTypes
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: AppText(
                                  e.tr,
                                  fontSize: size.width * 0.032,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            controller.bonusRules[index] = BonusRule(
                              type: v,
                              points: rule.points,
                              enabled: rule.enabled,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(width: size.width * 0.025),

                /// toggle
                GestureDetector(
                  onTap: () => controller.toggleRule(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 23,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: rule.enabled
                          ? _accent
                          : isDark
                              ? Colors.white.withOpacity(0.12)
                              : Colors.black.withOpacity(0.10),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      alignment: rule.enabled
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ── MIDDLE ROW: pts input (expanded) + delete ─────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.038,
              size.width * 0.030,
              size.width * 0.038,
              size.width * 0.018,
            ),
            child: Row(
              children: [
                /// points input — takes all remaining width
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          controller.updatePoints(index, int.tryParse(v) ?? 0),
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "0 pts",
                        hintStyle: TextStyle(
                          fontSize: size.width * 0.032,
                          color: isDark
                              ? Colors.white.withOpacity(0.25)
                              : Colors.black.withOpacity(0.20),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: _accent.withOpacity(0.07),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: _accent.withOpacity(0.22)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: _accent.withOpacity(0.55), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: size.width * 0.025),

                /// delete — fixed size, same height as input
                GestureDetector(
                  onTap: () => controller.removeRule(index),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.red.withOpacity(0.07),
                    ),
                    child: const Icon(
                      Iconsax.trash,
                      color: Colors.redAccent,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ── BOTTOM: description ──────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              size.width * 0.038,
              0,
              size.width * 0.038,
              size.width * 0.030,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppText(
                desc,
                fontSize: size.width * 0.028,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.45),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Size size;

  static const _accent = Color(0xFFE8640C);

  const _EmptyState({required this.isDark, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.grey.withOpacity(0.04),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.gift,
            size: size.width * 0.09,
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.12),
          ),
          SizedBox(height: size.height * 0.012),
          AppText(
            "no_bonus_rules".tr,
            fontSize: size.width * 0.034,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withOpacity(0.30)
                : Colors.black.withOpacity(0.30),
          ),
          SizedBox(height: size.height * 0.005),
          AppText(
            "add_first_rule".tr,
            fontSize: size.width * 0.029,
            color: isDark
                ? Colors.white.withOpacity(0.20)
                : Colors.black.withOpacity(0.20),
          ),
        ],
      ),
    );
  }
}