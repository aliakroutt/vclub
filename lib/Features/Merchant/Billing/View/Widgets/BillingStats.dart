import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/InvoicesController.dart';
import 'package:vclub/Features/Merchant/Billing/Models/SmsAddonModel.dart';

class BillingStatsRow extends StatelessWidget {
  const BillingStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<InvoicesController>()) {
      Get.put(InvoicesController());
    }

    final controller = Get.find<InvoicesController>();

    return Obx(() {
      final summary = controller.summary.value;
      final loading = controller.loading.value && !controller.initialLoaded.value;

      final totalPayments = summary?.succeededCount.toString() ?? "—";
      final totalPaid = summary != null ? formatMoney(summary.totalPaidValue, summary.currency) : "—";
      final lastPaymentDate = summary?.lastPaymentAt != null
          ? DateFormat('d MMM yyyy').format(summary!.lastPaymentAt!)
          : "—";
      final lastPaymentAmount = summary != null ? formatMoney(summary.lastAmountValue, summary.currency) : "—";

      final stats = [
        {
          "title": "total_payments".tr,
          "value": totalPayments,
          "subtitle": "successful_transactions".tr,
          "icon": Iconsax.card,
          "color": const Color(0xFF6C5CE7),
        },
        {
          "title": "total_amount_paid".tr,
          "value": totalPaid,
          "subtitle": "excluding_refunds".tr,
          "icon": Iconsax.wallet_money,
          "color": const Color(0xFF00B894),
        },
        {
          "title": "last_payment".tr,
          "value": lastPaymentDate,
          "subtitle": lastPaymentAmount,
          "icon": Iconsax.calendar,
          "color": const Color(0xFFFFC542),
        },
      ];

      return Column(
        children: List.generate(
          stats.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _BillingStatCard(
              title: stats[index]["title"] as String,
              value: stats[index]["value"] as String,
              subtitle: stats[index]["subtitle"] as String,
              icon: stats[index]["icon"] as IconData,
              color: stats[index]["color"] as Color,
              loading: loading,
            ),
          ),
        ),
      );
    });
  }
}

class _BillingStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool loading;

  const _BillingStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .22 : .04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: size.width * .14,
            height: size.width * .14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(.18), color.withOpacity(.05)],
              ),
            ),
            child: Icon(icon, color: color, size: size.width * .055),
          ),
          SizedBox(width: size.width * .04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: size.width * .034,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                ),
                SizedBox(height: size.height * .005),
                loading
                    ? Container(
                        width: size.width * .22,
                        height: size.width * .05,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                    : AppText(value, fontSize: size.width * .052, fontWeight: FontWeight.w800),
                SizedBox(height: size.height * .004),
                AppText(
                  subtitle,
                  fontSize: size.width * .030,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}