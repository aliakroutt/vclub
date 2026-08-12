import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class DownloadProgressController {
  final ValueNotifier<double> progress = ValueNotifier(0);
  final ValueNotifier<bool> indeterminate = ValueNotifier(true);

  void update(int received, int total) {
    if (total <= 0) {
      indeterminate.value = true;
      return;
    }
    indeterminate.value = false;
    progress.value = received / total;
  }

  void dispose() {
    progress.dispose();
    indeterminate.dispose();
  }
}

Future<void> showDownloadProgressSheet(
  BuildContext context,
  DownloadProgressController controller,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(26, 34, 26, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? .4 : .08),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _PulsingDownloadIcon(),
              const SizedBox(height: 22),
              AppText("downloading_invoice".tr, fontSize: 16.5, fontWeight: FontWeight.w800),
              const SizedBox(height: 6),
              AppText(
                "downloading_invoice_subtitle".tr,
                fontSize: 12.5,
                textAlign: TextAlign.center,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55),
              ),
              const SizedBox(height: 26),

              // ── progress bar + percentage ──
              ValueListenableBuilder<bool>(
                valueListenable: controller.indeterminate,
                builder: (context, indeterminate, _) {
                  return ValueListenableBuilder<double>(
                    valueListenable: controller.progress,
                    builder: (context, value, __) {
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 8,
                              child: indeterminate
                                  ? _IndeterminateBar(isDark: isDark)
                                  : TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0, end: value.clamp(0, 1)),
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOut,
                                      builder: (context, animatedValue, _) {
                                        return Stack(
                                          children: [
                                            Container(
                                              color: isDark
                                                  ? Colors.white.withOpacity(.08)
                                                  : Colors.black.withOpacity(.06),
                                            ),
                                            FractionallySizedBox(
                                              widthFactor: animatedValue,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors.primary,
                                                      AppColors.primary.withOpacity(.7),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppText(
                            indeterminate
                                ? "please_wait".tr
                                : "${(value * 100).clamp(0, 100).toStringAsFixed(0)}%",
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Soft pulsing gradient badge with the download icon, breathing in a loop
/// while the file transfers — gives the sheet a sense of life instead of
/// a static spinner.
class _PulsingDownloadIcon extends StatefulWidget {
  const _PulsingDownloadIcon();

  @override
  State<_PulsingDownloadIcon> createState() => _PulsingDownloadIconState();
}

class _PulsingDownloadIconState extends State<_PulsingDownloadIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _ringOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _ringOpacity = Tween<double>(begin: .35, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      width: 92,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // outer breathing ring
              Transform.scale(
                scale: _scale.value,
                child: Container(
                  height: 92,
                  width: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(_ringOpacity.value),
                  ),
                ),
              ),
              // mid ring
              Container(
                height: 74,
                width: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(.1),
                ),
              ),
              // icon badge
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primary.withOpacity(.75)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Iconsax.document_download, color: Colors.white, size: 24),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Animated indeterminate bar (sliding gradient sweep) used when total
/// file size isn't known yet (server hasn't sent Content-Length).
class _IndeterminateBar extends StatefulWidget {
  final bool isDark;

  const _IndeterminateBar({required this.isDark});

  @override
  State<_IndeterminateBar> createState() => _IndeterminateBarState();
}

class _IndeterminateBarState extends State<_IndeterminateBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: widget.isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth * .35;
                final travel = constraints.maxWidth + barWidth;
                final x = -barWidth + (_controller.value * travel);

                return Transform.translate(
                  offset: Offset(x, 0),
                  child: Container(
                    width: barWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0),
                          AppColors.primary,
                          AppColors.primary.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}