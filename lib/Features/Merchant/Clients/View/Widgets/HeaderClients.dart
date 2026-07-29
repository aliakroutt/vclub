import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class ClientsHeader extends StatefulWidget {
  final TextEditingController searchController;
  final VoidCallback onAdd;
  final ValueChanged<String> onChanged;
  final int clientCount;

  const ClientsHeader({
    super.key,
    required this.searchController,
    required this.onAdd,
    required this.onChanged,
    required this.clientCount,
  });

  @override
  State<ClientsHeader> createState() => _ClientsHeaderState();
}

class _ClientsHeaderState extends State<ClientsHeader> {
  late final FocusNode _focus;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()
      ..addListener(() {
        setState(() => _isFocused = _focus.hasFocus);
      });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary.withOpacity(0.25), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.people_copy, size: 14, color: primary),
              const SizedBox(width: 6),
              Text(
                '${'${widget.clientCount}'} ${'clients'.tr}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Search + Add row ──────────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.03),
            border: Border.all(
              color: _isFocused
                  ? primary.withOpacity(0.45)
                  : isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.07),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.search_normal_copy,
                size: 18,
                color: _isFocused
                    ? primary
                    : isDark
                    ? Colors.white.withOpacity(0.30)
                    : Colors.black.withOpacity(0.28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.searchController,
                  focusNode: _focus,
                  onChanged: widget.onChanged,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF111111),
                  ),
                  decoration: InputDecoration(
                    hintText: 'search_client'.tr,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? Colors.white.withOpacity(0.25)
                          : Colors.black.withOpacity(0.25),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
