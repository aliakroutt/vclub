import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';
import 'package:vclub/Features/Client/MyProfile/View/Widgets/ClubProgramSheet.dart';

/// Clubs section — now a single wrapping grid of circular club avatars
/// (progress ring + logo). Tapping a circle opens the ClubProgramsSheet
/// with every program the client has under that company.
class ClubsSection extends StatelessWidget {
  final List<ClientCardModel> cards;
  final bool isLoading;

  const ClubsSection({
    super.key,
    required this.cards,
    this.isLoading = false,
    // kept for backwards compatibility with existing call sites that
    // still pass a scrollController — no longer used internally.
    ScrollController? scrollController,
  });

  Map<String, List<ClientCardModel>> _groupByCompany() {
    final Map<String, List<ClientCardModel>> grouped = {};
    for (final c in cards) {
      grouped.putIfAbsent(c.company.id, () => []).add(c);
    }
    return grouped;
  }

  double _companyProgress(List<ClientCardModel> programs) {
    if (programs.isEmpty) return 0;
    double total = 0;
    for (final p in programs) {
      final mode = p.program.mode.toLowerCase();
      double v;
      if (mode.contains('stamp')) {
        final per = p.program.stampsPerReward;
        v = per > 0 ? (p.stamps % per) / per : 0;
      } else if (mode.contains('cashback')) {
        v = 1.0;
      } else {
        final per = p.program.pointsPerReward;
        v = per > 0 ? (p.points % per) / per : 0;
      }
      total += v;
    }
    return (total / programs.length).clamp(0.0, 1.0);
  }

  void _openSheet(BuildContext context, CompanyModel company, List<ClientCardModel> programs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClubProgramsSheet(company: company, programs: programs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    final grouped = _groupByCompany();
    final entries = grouped.entries.toList()..sort((a, b) => b.value.length.compareTo(a.value.length));

    const cols = 4;
    const spacing = 14.0;
    final itemWidth = (size.width - 32 - spacing * (cols - 1)) / cols;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: isLoading
          ? _CirclesShimmer(isDark: isDark, itemWidth: itemWidth)
          : entries.isEmpty
              ? const _EmptyClubsState()
              : Wrap(
                  spacing: spacing,
                  runSpacing: spacing + 6,
                  children: [
                    for (final entry in entries)
                      SizedBox(
                        width: itemWidth,
                        child: _StoryAvatar(
                          company: entry.value.first.company,
                          progress: _companyProgress(entry.value),
                          programCount: entry.value.length,
                          onTap: () => _openSheet(context, entry.value.first.company, entry.value),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final CompanyModel company;
  final double progress;
  final int programCount;
  final VoidCallback onTap;

  const _StoryAvatar({
    required this.company,
    required this.progress,
    required this.programCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            SizedBox(
              width: 66,
              height: 66,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => CustomPaint(
                      size: const Size(66, 66),
                      painter: _RingPainter(progress: v, color: AppColors.primary, isDark: isDark),
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: isDark
                          ? []
                          : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: ClipOval(
                      child: Container(
                        color: AppColors.primary.withOpacity(0.08),
                        child: company.logo.isNotEmpty
                            ? Image.network(
                                company.logo,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(Iconsax.shop, color: AppColors.primary, size: 18),
                              )
                            : Icon(Iconsax.shop, color: AppColors.primary, size: 18),
                      ),
                    ),
                  ),
                  if (programCount > 1)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        ),
                        child: Text(
                          '$programCount',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            AppText(
              company.name,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;
  const _RingPainter({required this.progress, required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 2.5;
    final track = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.10) : color.withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.5708, progress * 6.28319, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}

class _EmptyClubsState extends StatelessWidget {
  const _EmptyClubsState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.10), shape: BoxShape.circle),
            child: Icon(Iconsax.cup, size: 24, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          AppText("no_clubs_joined_yet".tr, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
        ],
      ),
    );
  }
}

class _CirclesShimmer extends StatelessWidget {
  final bool isDark;
  final double itemWidth;
  const _CirclesShimmer({required this.isDark, required this.itemWidth});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05);
    return Wrap(
      spacing: 14,
      runSpacing: 20,
      children: List.generate(
        8,
        (_) => SizedBox(
          width: itemWidth,
          child: Column(
            children: [
              Container(width: 66, height: 66, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(height: 8),
              Container(width: itemWidth * 0.6, height: 9, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: color)),
            ],
          ),
        ),
      ),
    );
  }
}