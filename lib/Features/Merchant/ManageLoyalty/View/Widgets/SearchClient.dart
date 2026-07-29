import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class PremiumSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const PremiumSearchField({
    super.key,
    required this.controller,
    this.hintText = 'search',
    this.onChanged,
    this.onClear,
  });

  @override
  State<PremiumSearchField> createState() =>
      _PremiumSearchFieldState();
}

class _PremiumSearchFieldState
    extends State<PremiumSearchField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _borderAnim;
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _borderAnim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    );

    _focusNode.addListener(() {
      _focusNode.hasFocus ? _ctrl.forward() : _ctrl.reverse();
      setState(() {});
    });

    widget.controller.addListener(() {
      final hasText = widget.controller.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _borderAnim,
      builder: (_, child) {
        return Container(
          height: size.height * .062,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(size.width * .04),
            border: Border.all(
              color: Color.lerp(
                AppColors.primary.withOpacity(.08),
                AppColors.primary.withOpacity(.55),
                _borderAnim.value,
              )!,
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(
                  .05 + (.05 * _borderAnim.value),
                ),
                blurRadius: 16 + (6 * _borderAnim.value),
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? .12 : .03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          SizedBox(width: size.width * .04),
          Icon(
            Iconsax.search_normal_copy,
            size: size.width * .052,
            color: AppColors.primary.withOpacity(.75),
          ),
          SizedBox(width: size.width * .026),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontSize: size.width * .036,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: AppColors.primary,
              cursorHeight: size.width * .045,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.hintText.tr,
                hintStyle: TextStyle(
                  fontSize: size.width * .036,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.withOpacity(.7),
                ),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: _hasText
                ? GestureDetector(
                    key: const ValueKey('clear'),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.controller.clear();
                      widget.onChanged?.call('');
                      widget.onClear?.call();
                      setState(() => _hasText = false);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: size.width * .026),
                      padding: EdgeInsets.all(size.width * .012),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: size.width * .036,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('empty'),
                    width: size.width * .04,
                  ),
          ),
        ],
      ),
    );
  }
}