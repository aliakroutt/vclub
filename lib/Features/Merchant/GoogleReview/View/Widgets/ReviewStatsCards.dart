import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';

class GoogleReviewsStatsColumn extends StatelessWidget {
  const GoogleReviewsStatsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stats = [
      {
        "title": "invitations_sent".tr,
        "value": 1240.0,
        "icon": Iconsax.send_2,
        "color": const Color(0xFF6C5CE7),
      },
      {
        "title": "link_clicks".tr,
        "value": 980.0,
        "icon": Iconsax.link_21,
        "color": const Color(0xFF00B894),
      },
      {
        "title": "reviews_generated".tr,
        "value": 430.0,
        "icon": Iconsax.star_1,
        "color": const Color(0xFFFFC542),
      },
      {
        "title": "rewards_given".tr,
        "value": 410.0,
        "icon": Iconsax.gift,
        "color": const Color(0xFF0984E3),
      },
    ];

    return Column(
      children: List.generate(stats.length, (index) {
        final item = stats[index];

        return Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.015),
          child: FadeSlide(
            delayMs: 200 + index * 100,
            child: _StatCard(
              title: item["title"].toString(),
              value: item["value"] as double,
              icon: item["icon"] as IconData,
              color: item["color"] as Color,
              isDark: isDark,
              size: size,
              delay: index * 80,
            ),
          ),
        );
      }),
    );
  }
}
class _StatCard extends StatefulWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final Size size;
  final int delay;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.size,
    required this.delay,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _start = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) setState(() => _start = true);
    });
  }

  String _format(double v) {
    if (v >= 1000) {
      return v.toInt().toString().replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (match) => ',',
          );
    }
    return v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.045,
        vertical: size.height * 0.018,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.25 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            width: size.width * 0.14,
            height: size.width * 0.14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withOpacity(0.18),
                  widget.color.withOpacity(0.05),
                ],
              ),
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: size.width * 0.055,
            ),
          ),

          SizedBox(width: size.width * 0.04),

          /// TITLE + VALUE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  widget.title,
                  fontSize: size.width * 0.034,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.6),
                ),
                SizedBox(height: size.height * 0.005),

                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(
                    begin: 0,
                    end: _start ? widget.value : 0,
                  ),
                  builder: (context, val, _) {
                    return AppText(
                      _format(val),
                      fontSize: size.width * 0.055,
                      fontWeight: FontWeight.w800,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}