import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';

class ClubProgramsSheet extends StatelessWidget {
  final CompanyModel company;
  final List<ClientCardModel> programs;

  const ClubProgramsSheet({super.key, required this.company, required this.programs});

  double get _initialSize {
    final v = 0.4 + (programs.length * 0.11);
    return v.clamp(0.42, 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: DraggableScrollableSheet(
        initialChildSize: _initialSize,
        minChildSize: 0.34,
        maxChildSize: 0.94,
        expand: false,
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4.5,
                    decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: AppColors.primary.withOpacity(0.09),
                            child: company.logo.isNotEmpty
                                ? Image.network(company.logo, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Iconsax.shop, color: AppColors.primary))
                                : Icon(Iconsax.shop, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(company.name, fontSize: 18, fontWeight: FontWeight.w800),
                              const SizedBox(height: 3),
                              AppText(
                                "${programs.length} ${programs.length == 1 ? 'program_joined'.tr : 'programs_joined'.tr}",
                                fontSize: 12.5,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05), shape: BoxShape.circle),
                            child: const Icon(Iconsax.close_circle, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
                      itemCount: programs.length,
                      itemBuilder: (context, index) => _SheetItemReveal(index: index, child: _ProgramCard(card: programs[index])),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SheetItemReveal extends StatefulWidget {
  final Widget child;
  final int index;
  const _SheetItemReveal({required this.child, required this.index});

  @override
  State<_SheetItemReveal> createState() => _SheetItemRevealState();
}

class _SheetItemRevealState extends State<_SheetItemReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 45 * widget.index.clamp(0, 8)), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: widget.child));
}

class _ProgramCard extends StatelessWidget {
  final ClientCardModel card;
  const _ProgramCard({required this.card});

  double get _progress {
    final mode = card.program.mode.toLowerCase();
    if (mode.contains('stamp')) {
      final per = card.program.stampsPerReward;
      if (per <= 0) return 0;
      return (card.stamps % per) / per;
    }
    if (mode.contains('cashback')) return 1.0;
    final per = card.program.pointsPerReward;
    if (per <= 0) return 0;
    return (card.points % per) / per;
  }

  String get _progressLabel {
    final mode = card.program.mode.toLowerCase();
    if (mode.contains('stamp')) {
      final per = card.program.stampsPerReward;
      final remaining = per > 0 ? per - (card.stamps % per) : 0;
      return per > 0 ? "${card.stamps} ${'stamps'.tr} • $remaining ${'to_next_reward'.tr}" : "${card.stamps} ${'stamps'.tr}";
    }
    if (mode.contains('cashback')) return "${card.cashbackBalance} ${'cashback_balance'.tr}";
    final per = card.program.pointsPerReward;
    final remaining = per > 0 ? per - (card.points % per) : 0;
    return per > 0 ? "${card.points} ${'pts'.tr} • $remaining ${'to_next_reward'.tr}" : "${card.points} ${'pts'.tr}";
  }

  IconData get _icon {
    final m = card.program.mode.toLowerCase();
    if (m.contains('stamp')) return Iconsax.tag;
    if (m.contains('cashback')) return Iconsax.wallet_3;
    return Iconsax.star_1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _progress.clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? Colors.white.withOpacity(0.045) : Colors.white,
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.045)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => CustomPaint(size: const Size(50, 50), painter: _MiniRingPainter(progress: v, color: AppColors.primary, isDark: isDark)),
                ),
                Icon(_icon, size: 17, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: AppText(card.program.name, fontSize: 14.5, fontWeight: FontWeight.w700, maxLines: 1)),
                    if (card.cardCompleted)
                      _badge("completed".tr, const Color(0xFF10B981))
                    else if (card.tier.isNotEmpty)
                      _badge(card.tier, AppColors.primary),
                  ],
                ),
                const SizedBox(height: 8),
                AppText(_progressLabel, fontSize: 12, color: Colors.grey),
                const SizedBox(height: 4),
                AppText("${card.visits} ${'visits'.tr}", fontSize: 11.5, color: Colors.grey.withOpacity(0.8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(20)),
        child: AppText(text.toUpperCase(), fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
      );
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;
  const _MiniRingPainter({required this.progress, required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 3;
    final track = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.5708, progress * 6.28319, false, arc);
  }

  @override
  bool shouldRepaint(covariant _MiniRingPainter oldDelegate) => oldDelegate.progress != progress;
}