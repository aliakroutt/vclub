import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Redemptions/Models/MerchantRedemptionModel.dart';
import 'RedemptionDetailSheet.dart';
import 'RedemptionMeta.dart';

class RedemptionCard extends StatelessWidget {
  final MerchantRedemptionItem item;
  final int index;

  const RedemptionCard({super.key, required this.item, this.index = 0});

  String _relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return "just_now".tr;
    if (diff.inMinutes < 60) return "${diff.inMinutes}${"minutes_short".tr}";
    if (diff.inHours < 24) return "${diff.inHours}${"hours_short".tr}";
    if (diff.inDays < 7) return "${diff.inDays}${"days_short".tr}";

    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = RedemptionMeta.of(item.status);
    final subColor = Theme.of(context).textTheme.bodySmall?.color;

    return FadeSlide(
      delayMs: (index * 50).clamp(0, 400),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          // color: isDark ? const Color(0xFF1C1F26) : Colors.white,
          // border: Border.all(
          //   color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.045),
          // ),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              spreadRadius: -10,
              offset: const Offset(0, 8),
              color: isDark ? Colors.black.withOpacity(.35) : Colors.black.withOpacity(.05),
            ),
          ],
        ),
        child: Material(
          // color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => showRedemptionDetailSheet(context, item),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── row 1: icon, reward/client, arrow ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [meta.color.withOpacity(.18), meta.color.withOpacity(.08)],
                          ),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(meta.icon, color: meta.color, size: 19),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              item.reward?.name ?? "reward_unnamed".tr,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.client != null) ...[
                              const SizedBox(height: 3),
                              AppText(
                                item.client!.fullName,
                                fontSize: 11.5,
                                overflow: TextOverflow.ellipsis,
                                color: subColor?.withOpacity(.6),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Iconsax.arrow_circle_right_copy, size: 15, color: subColor?.withOpacity(.35)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── row 2: date, spacer, status pill ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppText(
                        _relativeDate(item.createdAt),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subColor?.withOpacity(.5),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: meta.color.withOpacity(.1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: AppText(
                          meta.labelKey.tr,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: meta.color,
                        ),
                      ),
                    ],
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