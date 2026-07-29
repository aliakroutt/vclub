import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';

class FortuneStatsGrid extends StatelessWidget {
  final int availableSpins;
  final int wins;
  final int participations;
  final double winRate; // 0.65 = 65%

  const FortuneStatsGrid({
    super.key,
    required this.availableSpins,
    required this.wins,
    required this.participations,
    required this.winRate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final isRTL = Get.locale?.languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    final List<Map<String, dynamic>> stats = [
      {
        "title": "available_spins".tr,
        "value": "$availableSpins",
        "icon": Iconsax.refresh_circle,
        "color": const Color(0xFF6C63FF),
      },
      {
        "title": "wins".tr,
        "value": "$wins",
        "icon": Iconsax.cup,
        "color": const Color(0xFF2ECC71),
      },
      {
        "title": "participations".tr,
        "value": "$participations",
        "icon": Iconsax.user_tick,
        "color": const Color(0xFF3498DB),
      },
      {
        "title": "win_rate".tr,
        "value": "${(winRate * 100).toInt()}%",
        "icon": Iconsax.activity,
        "color": const Color(0xFFF39C12),
      },
    ];

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: 1.4,
        ),
        itemBuilder: (context, i) {
          return _FortuneStatCard(
            title: stats[i]["title"],
            value: stats[i]["value"],
            icon: stats[i]["icon"],
            color: stats[i]["color"],
            isDark: isDark,
          );
        },
      ),
    );
  }
}
class _FortuneStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _FortuneStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  State<_FortuneStatCard> createState() => _FortuneStatCardState();
}

class _FortuneStatCardState extends State<_FortuneStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final iconSize = size.width * 0.05;
    final valueSize = size.width * 0.055;
    final titleSize = size.width * 0.03;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: EdgeInsets.all(size.width * 0.04),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.9),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  widget.isDark ? 0.25 : 0.08,
                ),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// ICON
              Container(
                padding: EdgeInsets.all(size.width * 0.02),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: widget.color.withOpacity(
                    widget.isDark ? 0.18 : 0.12,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: iconSize,
                ),
              ),

              /// VALUE
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w800,
                  color: widget.color,
                ),
              ),

              /// TITLE
              AppText(
                widget.title,
                fontSize: titleSize,
                fontWeight: FontWeight.w400,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}