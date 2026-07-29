import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Client/Rewards/Controllers/RewardsClientController.dart';

class RewardsTabBar extends StatelessWidget {
  final bool isDark;

  const RewardsTabBar({super.key, required this.isDark});

  static const _tabs = [
    (icon: Iconsax.award, key: "tab_programs"),
    (icon: Iconsax.gift, key: "tab_fortune"),
    (icon: Iconsax.star, key: "tab_review"),
  ];

  @override
  Widget build(BuildContext context) {
    final tabController = Get.find<GoogleReviewController>();
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 360;

    final bgColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.045);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.06);

    return Container(
      height: isCompact ? 46 : 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / _tabs.length;

          return Obx(() {
            final selected = tabController.selectedIndex.value;

            return Stack(
              children: [
                // Sliding indicator pill — RTL-safe version
                AnimatedPositionedDirectional(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  start:
                      segmentWidth *
                      selected, // was: left: segmentWidth * selected
                  width: segmentWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: List.generate(_tabs.length, (index) {
                    final tab = _tabs[index];
                    final isSelected = selected == index;

                    return Expanded(
                      child: _TabItem(
                        icon: tab.icon,
                        label: tab.key.tr,
                        isSelected: isSelected,
                        isDark: isDark,
                        isCompact: isCompact,
                        onTap: () => tabController.select(index),
                      ),
                    );
                  }),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}

class _TabItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final bool isCompact;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.isCompact,
    required this.onTap,
  });

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.white;
    final inactiveColor = widget.isDark
        ? Colors.white.withOpacity(0.55)
        : Colors.black.withOpacity(0.45);

    final color = widget.isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          height: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: widget.isCompact ? 11.5 : 12.5,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w600,
                  color: color,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: widget.isCompact ? 15 : 16,
                      color: color,
                    ),
                    SizedBox(width: widget.isCompact ? 4 : 6),
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
