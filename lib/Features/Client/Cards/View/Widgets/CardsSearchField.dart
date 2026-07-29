import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Features/Client/Cards/Controllers/ClientCradsController.dart';


class CardsSearchField extends StatefulWidget {
  const CardsSearchField({super.key});

  @override
  State<CardsSearchField> createState() => _CardsSearchFieldState();
}

class _CardsSearchFieldState extends State<CardsSearchField> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _isFocused = false;

  final ClientCardsController controller = ClientCardsController.to;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      controller.setSearchQuery(value);
    });
    setState(() {}); // updates clear-button visibility
  }

  void _clear() {
    _textController.clear();
    controller.setSearchQuery("");
    setState(() {});
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : theme.colorScheme.primary.withOpacity(0.04),
        border: Border.all(
          color: _isFocused
              ? theme.colorScheme.primary.withOpacity(0.6)
              : (isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06)),
          width: 1.4,
        ),
        
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Iconsax.search_normal_1_copy,
            size: 20,
            color: _isFocused
                ? theme.colorScheme.primary
                : theme.textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              onChanged: _onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: "search_cards_hint".tr,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                ),
              ),
            ),
          ),
          if (_textController.text.isNotEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _clear,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.08),
                ),
                child: Icon(
                  Iconsax.close_circle,
                  size: 16,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            )
          else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}