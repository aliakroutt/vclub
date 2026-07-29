// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';

class ClientTabs extends StatelessWidget {
  final controller;

  const ClientTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final isRTL = Get.locale?.languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    final tabs = [
      // 'my_cards'.tr,
      'rewards'.tr,
      'history'.tr,
    ];

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.primary.withOpacity(0.08),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.15),
          ),
        ),
        child: Obx(
          () => Row(
            children: List.generate(tabs.length, (i) {
              final isSelected = controller.selectedIndex.value == i;

              return Expanded(
                child: _TabItem(
                  title: tabs[i],
                  isSelected: isSelected,
                  onTap: () => controller.changeTab(i),
                  size: size,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
class _TabItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Size size;

  const _TabItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.size,
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
      duration: const Duration(milliseconds: 180),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _TabItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected && !oldWidget.isSelected) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(
                vertical: widget.size.height * 0.012,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: widget.isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: AppText(
                  widget.title,
                  fontSize: widget.size.width * 0.032,
                  fontWeight: FontWeight.w600,
                  color: widget.isSelected
                      ? Colors.white
                      : Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.7),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}