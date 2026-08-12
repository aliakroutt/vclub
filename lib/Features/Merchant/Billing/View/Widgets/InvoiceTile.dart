import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Models/InvoiceModel.dart';
import 'package:vclub/Features/Merchant/Billing/Models/SmsAddonModel.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/InvoiceActions.dart';

class InvoiceTile extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoiceTile({super.key, required this.invoice});

  @override
  State<InvoiceTile> createState() => _InvoiceTileState();
}

class _InvoiceTileState extends State<InvoiceTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _reveal;

  static const _teal = Color(0xFF00C896);
  static const _accent = Color(0xFF7C6FF7);

  bool get _isAr => Get.locale?.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _reveal = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _open() => _ctrl.forward();
  void _close() => _ctrl.reverse();

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (_isAr) {
      if (v > 200) _open();
      if (v < -200) _close();
    } else {
      if (v < -200) _open();
      if (v > 200) _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final actionsW = size.width * .26;

    return GestureDetector(
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: size.height * .088,
        child: AnimatedBuilder(
          animation: _reveal,
          builder: (_, __) {
            final offset = actionsW * _reveal.value;

            return Stack(
              children: [
                Positioned(
  top: 0,
  bottom: 0,
  left: _isAr ? 0 : null,
  right: _isAr ? null : 0,
  width: actionsW,
  child: _ActionButtons(
    teal: _teal,
    accent: _accent,
    isAr: _isAr,
    onDownload: () async {
      _close();
      await InvoiceActions.downloadPdf(context,widget.invoice);
    },
    onOpen: () async {
      _close();
      await InvoiceActions.openInBrowser(widget.invoice);
    },
  ),
),
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(_isAr ? offset : -offset, 0),
                    child: _InvoiceTileContent(invoice: widget.invoice),
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

class _ActionButtons extends StatelessWidget {
  final Color teal;
  final Color accent;
  final VoidCallback onDownload;
  final VoidCallback onOpen;
  final bool isAr;

  const _ActionButtons({
    required this.teal,
    required this.accent,
    required this.onDownload,
    required this.onOpen,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final download = _ActionBtn(icon: Iconsax.document_download, color: teal, onTap: onDownload, size: size);
    final open = _ActionBtn(icon: Iconsax.global, color: accent, onTap: onOpen, size: size);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: isAr
          ? [open, SizedBox(width: size.width * .02), download]
          : [download, SizedBox(width: size.width * .02), open],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Size size;

  const _ActionBtn({required this.icon, required this.color, required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    final s = size.width * .108;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: color.withOpacity(.11),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(.22), width: 1),
        ),
        child: Icon(icon, color: color, size: s * .44),
      ),
    );
  }
}

class _InvoiceTileContent extends StatelessWidget {
  final InvoiceModel invoice;

  const _InvoiceTileContent({required this.invoice});

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
      child: Row(
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
              AppText(
                formatMoney(invoice.amountValue, invoice.currency),
                fontWeight: FontWeight.w900,
                fontSize: size.width * .040,
                color: AppColors.primary,
              ),
              SizedBox(height: size.height * .004),
              AppText(
                "invoice_amount_label".tr,
                fontWeight: FontWeight.w500,
                fontSize: size.width * .026,
                color: isDark ? Colors.white.withOpacity(.35) : Colors.black.withOpacity(.35),
              ),
            ],
          ),
        ],
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