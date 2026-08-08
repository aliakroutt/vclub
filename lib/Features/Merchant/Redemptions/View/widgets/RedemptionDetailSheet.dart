import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Redemptions/Models/MerchantRedemptionModel.dart';
import 'RedemptionMeta.dart';

Future<void> showRedemptionDetailSheet(BuildContext context, MerchantRedemptionItem item) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final meta = RedemptionMeta.of(item.status);

  String fullDate(DateTime d) {
    const months = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"];
    final m = months[d.month - 1].tr;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return "${d.day} $m ${d.year} • $hh:$mm";
  }

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [meta.color.withOpacity(.2), meta.color.withOpacity(.08)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(meta.icon, color: meta.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            item.reward?.name ?? "reward_unnamed".tr,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                          ),
                          const SizedBox(height: 3),
                          AppText(
                            meta.labelKey.tr,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: meta.color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (item.cost > 0) ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(.2)),
                    ),
                    child: Center(
                      child: AppText(
                        "${item.cost} ${"points_label".tr}",
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 22),
                AppText(
                  "details".tr,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.45),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.025),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      if (item.client != null)
                        _DetailRow(icon: Iconsax.user, label: "client_label".tr, value: item.client!.fullName),
                      if (item.validatedBy != null)
                        _DetailRow(icon: Iconsax.user_tag, label: "validated_by_label".tr, value: item.validatedBy!.fullName),
                      _DetailRow(icon: Iconsax.ticket, label: "reward_code_label".tr, value: item.code),
                      if (item.source.isNotEmpty)
                        _DetailRow(icon: Iconsax.flash_1, label: "source_label".tr, value: item.source == 'auto' ? "source_auto".tr : "source_manual".tr),
                      _DetailRow(icon: Iconsax.calendar_1, label: "date_time_label".tr, value: fullDate(item.createdAt), isLast: true),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Material(
                    color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(sheetContext),
                      child: Center(
                        child: AppText("close".tr, fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.04))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary.withOpacity(.7)),
          const SizedBox(width: 10),
          // AppText(label, fontSize: 12.5, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55)),
          // const Spacer(),
          Flexible(
            child: AppText(
              value,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}