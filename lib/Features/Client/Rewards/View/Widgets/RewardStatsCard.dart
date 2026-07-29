import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class RewardsStatsRow extends StatelessWidget {
  final bool isDark;
  final int programsPoints;
  final int fortunePoints;
  final VoidCallback? onProgramsTap;
  final VoidCallback? onFortuneTap;

  const RewardsStatsRow({
    super.key,
    required this.isDark,
    required this.programsPoints,
    required this.fortunePoints,
    this.onProgramsTap,
    this.onFortuneTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Responsive gap & padding — tighter on small phones, roomier on tablets
    final gap = width < 360 ? 8.0 : (width < 600 ? 12.0 : 16.0);
    final cardPadding = width < 360 ? 12.0 : 14.0;

    return Row(
      children: [
        Expanded(
          child: _RewardStatCard(
            isDark: isDark,
            icon: Iconsax.award,
            label: "programs_rewards".tr,
            value: programsPoints,
            accent: AppColors.primary,
            padding: cardPadding,
            onTap: onProgramsTap,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _RewardStatCard(
            isDark: isDark,
            icon: Iconsax.gift,
            label: "fortune_rewards".tr,
            value: fortunePoints,
            accent: const Color(0xFFD8A657), // gold-ish accent for "fortune"
            padding: cardPadding,
            onTap: onFortuneTap,
          ),
        ),
      ],
    );
  }
}

class _RewardStatCard extends StatefulWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  final int value;
  final Color accent;
  final double padding;
  final VoidCallback? onTap;

  const _RewardStatCard({
    required this.isDark,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.padding,
    this.onTap,
  });

  @override
  State<_RewardStatCard> createState() => _RewardStatCardState();
}

class _RewardStatCardState extends State<_RewardStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 360;

    final bgColor = widget.isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.85);
    final borderColor = widget.isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.06);
    final labelColor = widget.isDark
        ? Colors.white.withOpacity(0.6)
        : Colors.black.withOpacity(0.5);

    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _ctrl.forward(),
      onTapUp: widget.onTap == null
          ? null
          : (_) async {
              await _ctrl.reverse();
              widget.onTap!();
            },
      onTapCancel: widget.onTap == null ? null : () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(
            horizontal: widget.padding,
            vertical: widget.padding,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.20 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: isCompact ? 30 : 34,
                    width: isCompact ? 30 : 34,
                    decoration: BoxDecoration(
                      color: widget.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icon,
                      size: isCompact ? 15 : 17,
                      color: widget.accent,
                    ),
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Text(
                      "${widget.value}",
                      key: ValueKey<int>(widget.value),
                      style: TextStyle(
                        fontSize: isCompact ? 17 : 19,
                        fontWeight: FontWeight.w800,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 8 : 10),
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isCompact ? 8 : 9,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}