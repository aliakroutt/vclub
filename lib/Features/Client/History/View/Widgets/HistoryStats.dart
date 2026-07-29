import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';

class PointsStatsRow extends StatelessWidget {
  final int earned;
  final int spent;
  final int bonuses;

  const PointsStatsRow({
    super.key,
    required this.earned,
    required this.spent,
    required this.bonuses,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final isRTL = Get.locale?.languageCode == 'ar';

    final List<Map<String, dynamic>> stats = [
      {
        "title": "points_earned".tr,
        "value": "+$earned",
        "icon": Iconsax.arrow_circle_up_copy,
        "color": const Color(0xFF2ECC71), // green
      },
      {
        "title": "points_spent".tr,
        "value": "-$spent",
        "icon": Iconsax.arrow_circle_down_copy,
        "color": const Color(0xFFE74C3C), // red
      },
      {
        "title": "bonuses_received".tr,
        "value": "+$bonuses",
        "icon": Iconsax.gift,
        "color": const Color(0xFFFF9800), // orange
      },
    ];

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, i) {
          return _StatCard(
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
class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isDark;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isDark,
    required this.color,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
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

    final iconSize = size.width * 0.045;
    final titleSize = size.width * 0.028;
    final valueSize = size.width * 0.045;
    final cardHeight = size.height * 0.13;

    Color valueColor = widget.color;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          height: cardHeight,
          padding: EdgeInsets.all(size.width * 0.03),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.78),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  widget.isDark ? 0.25 : 0.08,
                ),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(size.width * 0.02),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: widget.color.withOpacity(
                    widget.isDark ? 0.18 : 0.12,
                  ),
                ),
                child: Icon(widget.icon, size: iconSize, color: widget.color),
              ),

              // VALUE (colored + bold)
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),

              // TITLE
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