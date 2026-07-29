import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Models/InvoiceModel.dart';

class InvoiceHistoryCard extends StatelessWidget {
  const InvoiceHistoryCard({super.key});

  static const _accent = Color(0xFF7C6FF7);

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final invoices = [
      InvoiceModel(date: "24 Août 2025 • 14:32", plan: "PREMIUM", amount: "€49.99", status: "succeeded"),
      InvoiceModel(date: "24 Jul 2025 • 09:18",  plan: "PREMIUM", amount: "€49.99", status: "succeeded"),
      InvoiceModel(date: "24 Jun 2025 • 16:41",  plan: "PREMIUM", amount: "€49.99", status: "succeeded"),
    ];

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.07)
              : Colors.black.withOpacity(.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .28 : .055),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _accent.withOpacity(.05),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: size.width * .105,
                height: size.width * .105,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _accent.withOpacity(.18)),
                ),
                child: Icon(
                  Iconsax.receipt_item,
                  color: _accent,
                  size: size.width * .050,
                ),
              ),
              SizedBox(width: size.width * .035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "invoice_history_title",
                      fontSize: size.width * .042,
                      fontWeight: FontWeight.w800,
                    ),
                    SizedBox(height: size.height * .003),
                    AppText(
                      "invoice_history_subtitle",
                      fontSize: size.width * .030,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withOpacity(.35)
                          : Colors.black.withOpacity(.38),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .024),

          // ── LIST ─────────────────────────────────────────
          ...List.generate(invoices.length, (i) {
            final isLast = i == invoices.length - 1;
            return Column(
              children: [
                _SwipeableInvoiceTile(invoice: invoices[i]),
                if (!isLast)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * .013),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? Colors.white.withOpacity(.055)
                          : Colors.black.withOpacity(.05),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── SWIPEABLE TILE ────────────────────────────────────────────────────────────

class _SwipeableInvoiceTile extends StatefulWidget {
  const _SwipeableInvoiceTile({required this.invoice});
  final InvoiceModel invoice;

  @override
  State<_SwipeableInvoiceTile> createState() =>
      _SwipeableInvoiceTileState();
}

class _SwipeableInvoiceTileState extends State<_SwipeableInvoiceTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _reveal; // 0 → 1

  static const _teal   = Color(0xFF00C896);
  static const _accent = Color(0xFF7C6FF7);

  // Whether Arabic locale is active (RTL → swipe right to reveal)
  bool get _isAr => Get.locale?.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _reveal = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _open()  => _ctrl.forward();
  void _close() => _ctrl.reverse();

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (_isAr) {
      // Arabic: swipe right (positive velocity) → open
      if (v > 200)  _open();
      if (v < -200) _close();
    } else {
      // LTR: swipe left (negative velocity) → open
      if (v < -200) _open();
      if (v > 200)  _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    // Reserve width for the two action buttons
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
                // ── ACTION BUTTONS ───────────────────────
                Positioned(
                  top: 0,
                  bottom: 0,
                  // Arabic: buttons on the left; LTR: buttons on the right
                  left:  _isAr ? 0 : null,
                  right: _isAr ? null : 0,
                  width: actionsW,
                  child: _ActionButtons(
                    teal: _teal,
                    accent: _accent,
                    onDownload: _close,
                    onOpen: _close,
                    isAr: _isAr,
                  ),
                ),

                // ── TILE (slides away) ───────────────────
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

// ── ACTION BUTTONS ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.teal,
    required this.accent,
    required this.onDownload,
    required this.onOpen,
    required this.isAr,
  });

  final Color teal;
  final Color accent;
  final VoidCallback onDownload;
  final VoidCallback onOpen;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final download = _ActionBtn(
      icon: Iconsax.document_download,
      color: teal,
      onTap: onDownload,
      size: size,
    );
    final open = _ActionBtn(
      icon: Iconsax.global,
      color: accent,
      onTap: onOpen,
      size: size,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: isAr
          ? [open, SizedBox(width: size.width * .02), download]
          : [download, SizedBox(width: size.width * .02), open],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.size,
  });

  final IconData  icon;
  final Color     color;
  final VoidCallback onTap;
  final Size      size;

  @override
  Widget build(BuildContext context) {
    final s = size.width * .108;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  s,
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

// ── TILE CONTENT ──────────────────────────────────────────────────────────────

class _InvoiceTileContent extends StatelessWidget {
  const _InvoiceTileContent({required this.invoice});
  final InvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
  padding: EdgeInsets.symmetric(
    horizontal: size.width * .04,
    vertical: size.height * .014,
  ),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: isDark ? const Color(0xFF23233A) : const Color(0xFFF7F7FB),
    border: Border.all(
      color: isDark
          ? Colors.white.withOpacity(.07)
          : Colors.black.withOpacity(.055),
    ),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // ── ICON ────────────────────────────────────────
      // Container(
      //   width: size.width * .11,
      //   height: size.width * .11,
      //   decoration: BoxDecoration(
      //     color: const Color(0xFF7C6FF7).withOpacity(.10),
      //     borderRadius: BorderRadius.circular(14),
      //     border: Border.all(
      //       color: const Color(0xFF7C6FF7).withOpacity(.18),
      //     ),
      //   ),
      //   child: Icon(
      //     Iconsax.receipt_item,
      //     color: const Color(0xFF7C6FF7),
      //     size: size.width * .048,
      //   ),
      // ),

      // SizedBox(width: size.width * .035),

      // ── LEFT: date + badges ──────────────────────────
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              invoice.date,
              fontWeight: FontWeight.w700,
              fontSize: size.width * .034,
            ),
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

      // ── RIGHT: amount ────────────────────────────────
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            invoice.amount,
            fontWeight: FontWeight.w900,
            fontSize: size.width * .040,
            color: AppColors.primary,
          ),
          SizedBox(height: size.height * .004),
          AppText(
            "invoice_amount_label",
            fontWeight: FontWeight.w500,
            fontSize: size.width * .026,
            color: isDark
                ? Colors.white.withOpacity(.35)
                : Colors.black.withOpacity(.35),
          ),
        ],
      ),
    ],
  ),
);
  }
}

// ── PLAN BADGE ────────────────────────────────────────────────────────────────

class _PlanBadge extends StatelessWidget {
  const _PlanBadge(this.plan);
  final String plan;

  static const _gold = Color(0xFFFFB930);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .022,
        vertical:   size.height * .004,
      ),
      decoration: BoxDecoration(
        color: _gold.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _gold.withOpacity(.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.diamonds, size: size.width * .028, color: _gold),
          SizedBox(width: size.width * .012),
          AppText(
            "plan_${plan.toLowerCase()}",
            color: _gold,
            fontSize: size.width * .026,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}

// ── STATUS BADGE ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);
  final String status;

  static const _green = Color(0xFF00C896);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .022,
        vertical:   size.height * .004,
      ),
      decoration: BoxDecoration(
        color: _green.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _green.withOpacity(.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  size.width * .016,
            height: size.width * .016,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _green,
            ),
          ),
          SizedBox(width: size.width * .013),
          AppText(
            "status_$status",
            color: _green,
            fontSize: size.width * .026,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}