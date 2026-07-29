// clients_tab_bar.dart
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';


enum ClientTab { all, active, inactive, vip, birthdays }


class ClientsTabBar extends StatelessWidget {
  final ClientTab selectedTab;
  final ValueChanged<ClientTab> onTabChanged;

  const ClientsTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  static const _tabs = [
    (tab: ClientTab.all,       key: 'all',       icon: Iconsax.element_4_copy),
    (tab: ClientTab.active,    key: 'active',    icon: Iconsax.tick_circle_copy),
    (tab: ClientTab.inactive,  key: 'inactive',  icon: Iconsax.close_circle_copy),
    (tab: ClientTab.vip,       key: 'vip',       icon: Iconsax.crown_copy),
    (tab: ClientTab.birthdays, key: 'birthdays', icon: Iconsax.cake_copy),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _tabs.map((t) {
          final isSelected = selectedTab == t.tab;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _TabPill(
              labelKey: t.key,
              icon: t.icon,
              isSelected: isSelected,
              onTap: () => onTabChanged(t.tab),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String labelKey;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.labelKey,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? primary
              : isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.white.withOpacity(0.40)
                      : Colors.black.withOpacity(0.35),
            ),
            const SizedBox(width: 6),
            AppText(
              labelKey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.white.withOpacity(0.40)
                      : Colors.black.withOpacity(0.40),
            ),
          ],
        ),
      ),
    );
  }
}