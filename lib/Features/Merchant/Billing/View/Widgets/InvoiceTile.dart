import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/CurrencyController.dart';
import 'package:vclub/Features/Merchant/Billing/Models/InvoiceModel.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/InvoiceActions.dart';

class InvoiceTile extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceTile({super.key, required this.invoice});

  static const _teal = Color(0xFF00C896);
  static const _accent = Color(0xFF7C6FF7);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateLabel = DateFormat('d MMM yyyy • HH:mm').format(invoice.createdAt);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * .04, vertical: size.height * .014),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF23233A) : const Color(0xFFF7F7FB),
        border: Border.all(color: isDark ? Colors.white.withOpacity(.07) : Colors.black.withOpacity(.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(dateLabel, fontWeight: FontWeight.w700, fontSize: size.width * .034),
                    SizedBox(height: size.height * .006),
                    Row(
                      children: [
                        _PlanBadge(invoice.plan),
                        SizedBox(width: size.width * .02),
                        _StatusBadge(invoice.status),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: size.width * .02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => AppText(
                        CurrencyController.to.formatAmount(invoice.amountValue),
                        fontWeight: FontWeight.w900,
                        fontSize: size.width * .040,
                        color: AppColors.primary,
                      )),
                  // SizedBox(height: size.height * .004),
                  // AppText(
                  //   "invoice_amount_label".tr,
                  //   fontWeight: FontWeight.w500,
                  //   fontSize: size.width * .026,
                  //   color: isDark ? Colors.white.withOpacity(.35) : Colors.black.withOpacity(.35),
                  // ),
                ],
              ),
            ],
          ),

          SizedBox(height: size.height * .014),

          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05),
          ),

          SizedBox(height: size.height * .012),

          // ── ACTION BUTTONS (in-card) ──
          Row(
            children: [
              Expanded(
                child: _PillActionButton(
                  icon: Iconsax.document_download,
                  label: "download_action".tr,
                  color: AppColors.primary,
                  size: size,
                  onTap: () async {
                    await InvoiceActions.downloadPdf(context, invoice);
                  },
                ),
              ),
              SizedBox(width: size.width * .022),
              Expanded(
                child: _PillActionButton(
                  icon: Iconsax.global,
                  label: "view_online_action".tr,
                  color: AppColors.primary,
                  size: size,
                  onTap: () async {
                    await InvoiceActions.openInBrowser(invoice);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillActionButton extends StatelessWidget {
  const _PillActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Size size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: size.height * .0105),
          decoration: BoxDecoration(
            color: color.withOpacity(.11),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: color.withOpacity(.22), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: size.width * .038),
              SizedBox(width: size.width * .017),
              Flexible(
                child: AppText(
                  label,
                  fontSize: size.width * .030,
                  fontWeight: FontWeight.w700,
                  color: color,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final String plan;

  const _PlanBadge(this.plan);

  static const _gold = Color(0xFFFFB930);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final label = plan.toUpperCase() == "SMS_ADDON" ? "sms_option_title".tr : "plan_${plan.toLowerCase()}".tr;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * .022, vertical: size.height * .004),
      decoration: BoxDecoration(
        color: _gold.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _gold.withOpacity(.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(plan.toUpperCase() == "SMS_ADDON" ? Iconsax.sms_notification : Iconsax.diamonds, size: size.width * .028, color: _gold),
          SizedBox(width: size.width * .012),
          AppText(label, color: _gold, fontSize: size.width * .026, fontWeight: FontWeight.w700),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSuccess = status.toLowerCase() == "succeeded";
    final color = isSuccess ? const Color(0xFF00C896) : Colors.redAccent;
    final label = isSuccess ? "status_succeeded".tr : "status_${status.toLowerCase()}".tr;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * .022, vertical: size.height * .004),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: size.width * .016, height: size.width * .016, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          SizedBox(width: size.width * .013),
          AppText(label, color: color, fontSize: size.width * .026, fontWeight: FontWeight.w700),
        ],
      ),
    );
  }
}