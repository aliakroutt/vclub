import 'package:flutter/material.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class ColorField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const ColorField({super.key, required this.controller, required this.label});

  Color? _parseColor(String hex) {
    var value = hex.trim();
    if (value.isEmpty) return null;
    if (!value.startsWith('#')) value = '#$value';
    if (value.length == 7) {
      try {
        return Color(int.parse(value.replaceFirst('#', '0xFF')));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: size.width * .031,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65),
        ),
        SizedBox(height: size.height * .008),
        Container(
          height: size.height * .062,
          padding: EdgeInsets.symmetric(horizontal: size.width * .035),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
            border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
          ),
          child: Row(
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      final color = _parseColor(controller.text);
                      return Container(
                        height: 22,
                        width: 22,
                        decoration: BoxDecoration(
                          color: color ?? Colors.grey.withOpacity(.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? Colors.white.withOpacity(.2) : Colors.black.withOpacity(.1)),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(width: size.width * .03),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(fontSize: size.width * .034, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: "#6C5CE7",
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(.5)),
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