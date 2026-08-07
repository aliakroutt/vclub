import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

const List<String> kQuickEmojis = [
  "😀","😁","😂","🤣","😊","😍","😘","😉","😎","🤩",
  "🥳","🙌","👏","💪","🔥","⭐","✨","🎉","🎁","❤️",
  "💛","💚","💙","👍","🙏","😢","😮","🤔","👋","✅",
  "🔔","📣","💰","🛍️","🏆","☕","🍕","🎯","📅","🚀",
];

Future<void> showEmojiPickerSheet(BuildContext context, void Function(String) onSelected) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F26) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                AppText("pick_emoji".tr, fontSize: 15, fontWeight: FontWeight.w800),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kQuickEmojis.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final emoji = kQuickEmojis[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    onSelected(emoji);
                    Navigator.pop(context);
                  },
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}