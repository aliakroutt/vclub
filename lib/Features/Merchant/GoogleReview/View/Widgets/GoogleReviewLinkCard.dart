import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class GoogleReviewLinkCard extends StatefulWidget {
  const GoogleReviewLinkCard({super.key});

  @override
  State<GoogleReviewLinkCard> createState() => _GoogleReviewLinkCardState();
}

class _GoogleReviewLinkCardState extends State<GoogleReviewLinkCard> {
  final TextEditingController controller = TextEditingController(
    text: "https://g.page/r/your-business-review-link",
  );

  void _copy() {
    Clipboard.setData(ClipboardData(text: controller.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Link copied")),
    );
  }

  void _share() {
    // Share.share(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * 0.038),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                width: size.width * 0.09,
                height: size.width * 0.09,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                ),
                child: const Icon(
                  Iconsax.link_21,
                  color: Color(0xFF6C5CE7),
                  size: 17,
                ),
              ),
              SizedBox(width: size.width * 0.025),
              AppText(
                "google_review_link",
                fontSize: size.width * 0.036,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),

          SizedBox(height: size.height * 0.012),

          /// LABEL
          AppText(
            "google_review_link_description",
            fontSize: size.width * 0.028,
            color: Colors.grey,
          ),

          SizedBox(height: size.height * 0.008),

          /// FIELD + BUTTONS IN ONE ROW
          Row(
            children: [
              /// EDITABLE FIELD
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.028,
                    vertical: size.height * 0.015,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDark
                        ? Colors.white.withOpacity(0.03)
                        : Colors.black.withOpacity(0.02),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    style: TextStyle(
                      fontSize: size.width * 0.028,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),

              SizedBox(width: size.width * 0.02),

              /// COPY BUTTON
              _ActionButton(
                icon: Iconsax.copy,
                label: "Copy",
                color: const Color(0xFF6C5CE7),
                onTap: _copy,
              ),

              SizedBox(width: size.width * 0.015),

              /// SHARE BUTTON
              _ActionButton(
                icon: Iconsax.share,
                label: "Share",
                color: const Color(0xFF00B894),
                onTap: _share,
              ),
            ],
          ),

          SizedBox(height: size.height * 0.012),

          /// IMPORTANT INFO CARD
          Container(
            padding: EdgeInsets.all(size.width * 0.025),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFFFC542).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFFFFC542).withOpacity(0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Iconsax.info_circle,
                  size: 15,
                  color: Color(0xFFB08000),
                ),
                SizedBox(width: size.width * 0.018),
                Expanded(
                  child: AppText(
                    "important_google_review_note",
                    fontSize: size.width * 0.028,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7A5500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= ACTION BUTTON =================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color.withOpacity(0.10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child:Icon(icon, size: 16, color: color),
      ),
    );
  }
}