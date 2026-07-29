import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class ProgramCreatedDialog extends StatefulWidget {
  final String? programName;
  final VoidCallback? onDone;

  const ProgramCreatedDialog({super.key, this.programName, this.onDone});

  /// Shows the dialog with backdrop blur + fade/scale entrance.
  static Future<void> show({String? programName, VoidCallback? onDone}) {
    return Get.dialog(
      ProgramCreatedDialog(programName: programName, onDone: onDone),
      barrierDismissible: false,
      // barrierColor: Colors.black.withOpacity(0.55),
    );
  }

  @override
  State<ProgramCreatedDialog> createState() => _ProgramCreatedDialogState();
}

class _ProgramCreatedDialogState extends State<ProgramCreatedDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.85, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.07,
                  vertical: size.height * 0.04,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: isDark
                      ? Colors.white
                      : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.white.withOpacity(0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ── SUCCESS ICON ──────────────────────
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: size.width * 0.24,
                          height: size.width * 0.24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.18),
                                AppColors.primary.withOpacity(0.04),
                              ],
                            ),
                          ),
                        ),
                        ScaleTransition(
                          scale: _checkScale,
                          child: Container(
                            width: size.width * 0.17,
                            height: size.width * 0.17,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.75),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Iconsax.tick_circle_copy,
                              color: Colors.white,
                              size: size.width * 0.09,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.028),

                    /// ── TITLE ──────────────────────────────
                     AppText(
                        "program_created_title".tr,
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.center,
                        color: AppColors.primary
                        
                      
                    ),

                    SizedBox(height: size.height * 0.01),

                    /// ── SUBTITLE ───────────────────────────
                 AppText(
                        widget.programName != null &&
                                widget.programName!.trim().isNotEmpty
                            ? "program_created_subtitle_named".trParams(
                                {"name": widget.programName!.trim()})
                            : "program_created_subtitle".tr,
                        fontSize: size.width * 0.033,
                        fontWeight: FontWeight.w400,
                        textAlign: TextAlign.center,
                        color: Theme.of(context).textTheme.bodySmall?.color
                      ),
                    

                    SizedBox(height: size.height * 0.032),

                    /// ── CTA BUTTON ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: size.height * 0.062,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back(); // close dialog
                          widget.onDone?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              "done".tr,
                              fontSize: size.width * 0.038,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Icon(
                              Iconsax.arrow_right_3,
                              size: size.width * 0.045,
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
          ),
        ),
      ),
    ));
  }
}