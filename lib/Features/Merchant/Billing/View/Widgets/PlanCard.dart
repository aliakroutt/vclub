import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Models/PlanModel.dart';
import 'package:vclub/Features/Merchant/Billing/Models/SmsAddonModel.dart';

class _TierStyle {
  final IconData icon;
  final Color color;

  const _TierStyle(this.icon, this.color);

  static _TierStyle of(String key) {
    switch (key.toUpperCase()) {
      case "STARTER":
        return const _TierStyle(Iconsax.flash_1, Color(0xFF3D8BFF));
      case "BUSINESS":
        return const _TierStyle(Iconsax.crown_1, AppColors.primary);
      case "PREMIUM":
        return const _TierStyle(Iconsax.diamonds, Color(0xFFB984FF));
      default:
        return const _TierStyle(Iconsax.medal_star, AppColors.primary);
    }
  }
}

class PlanCard extends StatelessWidget {
  final PlanDisplayModel plan;
  final bool isCurrent;
  final VoidCallback onSelect;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isCurrent,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final popular = plan.features.popular;
    final tier = _TierStyle.of(plan.price.key);
    final accent = popular ? tier.color : tier.color;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: popular
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withOpacity(isDark ? .16 : .08),
                  isDark ? const Color(0xFF1C1F26) : Colors.white,
                ],
              )
            : null,
        color: popular ? null : (isDark ? const Color(0xFF1C1F26) : Colors.white),
        border: Border.all(
          color: popular
              ? accent.withOpacity(.45)
              : (isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06)),
          width: popular ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: popular ? accent.withOpacity(.2) : Colors.black.withOpacity(isDark ? .3 : .045),
            blurRadius: popular ? 28 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── header: icon badge, title, popular/current badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [accent, accent.withOpacity(.7)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: accent.withOpacity(.35), blurRadius: 14, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Icon(tier.icon, color: Colors.white, size: 21),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(plan.features.titleKey.tr, fontSize: 16.5, fontWeight: FontWeight.w800),
                           if (popular && !isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [accent, accent.withOpacity(.75)]),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Iconsax.star, size: 10, color: Colors.white),
                                  const SizedBox(width: 3),
                                  AppText("most_popular".tr, fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AppText(
                            formatMoney(plan.price.amountValue, plan.price.currency),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: accent,
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            "/ ${"month".tr}",
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C896),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFF00C896)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 6,
                          width: 6,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        AppText("current_plan".tr, fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
            const SizedBox(height: 14),

            // ── feature list ──
            ...plan.features.featureKeys.map((key) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 1),
                        height: 19,
                        width: 19,
                        decoration: BoxDecoration(color: accent.withOpacity(.12), shape: BoxShape.circle),
                        child: Icon(Iconsax.tick_circle, size: 12.5, color: accent),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppText(key.tr, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.3),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 6),

            // ── CTA button ──
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Material(
                color: isCurrent
                    ? Colors.transparent
                    : (popular ? null : (isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.045))),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: (!isCurrent && popular)
                        ? LinearGradient(colors: [accent, accent.withOpacity(.8)])
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    border: isCurrent
                        ? Border.all(color: isDark ? Colors.white.withOpacity(.12) : Colors.black.withOpacity(.08))
                        : null,
                    boxShadow: (!isCurrent && popular)
                        ? [BoxShadow(color: accent.withOpacity(.32), blurRadius: 14, offset: const Offset(0, 6))]
                        : [],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: isCurrent ? null : onSelect,
                    child: Center(
                      child: isCurrent
                          ? AppText(
                              "active_plan".tr,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppText(
                                  "choose_this_plan".tr,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: popular ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Iconsax.arrow_circle_right_copy,
                                  size: 15,
                                  color: popular ? Colors.white : accent,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}