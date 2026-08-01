import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelController.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showValidationErrorsDialog(
  BuildContext context,
  List<ValidationIssue> issues,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  const accent = Color(0xFFE5484D);

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'validation_errors',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, __, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.86 + (0.14 * curved.value),
          child: _ValidationDialogContent(
            issues: issues,
            isDark: isDark,
            accent: accent,
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG BODY
// ─────────────────────────────────────────────────────────────────────────────

class _ValidationDialogContent extends StatelessWidget {
  final List<ValidationIssue> issues;
  final bool isDark;
  final Color accent;

  const _ValidationDialogContent({
    required this.issues,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width * 0.86,
          constraints: BoxConstraints(maxHeight: size.height * 0.72),
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF18181B) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.55 : 0.18),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon badge with glow ──────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(0.08),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(0.14),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(Iconsax.warning_2, color: accent, size: 28),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              AppText(
                'validation_title'.tr,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(height: 6),
              AppText(
                'validation_subtitle'.trParams({'count': '${issues.length}'}),
                fontSize: 12.5,
                textAlign: TextAlign.center,
                color: isDark
                    ? Colors.white.withOpacity(0.45)
                    : Colors.black.withOpacity(0.45),
              ),

              const SizedBox(height: 20),

              // ── Issues list ───────────────────────────────────────────
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: issues.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final issue = issues[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: accent.withOpacity(isDark ? 0.09 : 0.055),
                        border: Border.all(color: accent.withOpacity(0.16)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withOpacity(0.15),
                            ),
                            child: Icon(issue.icon, size: 14, color: accent),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: AppText(
                                issue.message,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white.withOpacity(0.85)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              // ── Action button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    elevation: 0,
                    shadowColor: accent.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ).copyWith(
                    elevation: WidgetStateProperty.resolveWith(
                      (states) =>
                          states.contains(WidgetState.pressed) ? 0 : 4,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.tick_circle, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      AppText(
                        'got_it'.tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}