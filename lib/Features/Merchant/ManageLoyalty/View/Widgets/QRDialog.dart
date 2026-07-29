// import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class ProgramQrDialog extends StatefulWidget {
  final String programLink;

  const ProgramQrDialog({
    super.key,
    required this.programLink,
  });

  @override
  State<ProgramQrDialog> createState() => _ProgramQrDialogState();
}

class _ProgramQrDialogState extends State<ProgramQrDialog> {
  final GlobalKey _qrBoundaryKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _downloadQr() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final hasAccess = await Gal.hasAccess() || await Gal.requestAccess();
      if (!hasAccess) {
        _showFeedback("qr_permission_denied".tr, success: false);
        return;
      }

      final boundary = _qrBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        _showFeedback("qr_save_failed".tr, success: false);
        return;
      }

      // Capture at a high pixel ratio so the saved PNG stays crisp/scannable.
      final image = await boundary.toImage(pixelRatio: 3.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(
        bytes,
        name: 'vclub_qr_${DateTime.now().millisecondsSinceEpoch}',
      );

      HapticFeedback.lightImpact();
      _showFeedback("qr_saved".tr, success: true);
    } catch (_) {
      _showFeedback("qr_save_failed".tr, success: false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showFeedback(String message, {required bool success}) {
    Get.snackbar(
      success ?  "success".tr : "error".tr ,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: (success ? AppColors.primary : const Color(0xFFE5484D))
          .withOpacity(.92),
      colorText: Colors.white,
      borderRadius: 14,
      icon: Icon(
        success ? Iconsax.tick_circle : Iconsax.warning_2,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Responsive tokens ───────────────────────────────────────────────
    final pad = size.width * .056;
    final radius = size.width * .072;
    final qrSize = size.width * .52;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * .055,
        vertical: size.height * .06,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.fromLTRB(pad, pad * .6, pad, pad),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              // ── Layered glass fill ─────────────────────────────────
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1E2233).withOpacity(.92),
                        const Color(0xFF141726).withOpacity(.96),
                      ]
                    : [
                        Colors.white.withOpacity(.95),
                        Colors.white.withOpacity(.90),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(.10)
                    : Colors.white.withOpacity(.80),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? .45 : .12),
                  blurRadius: 50,
                  spreadRadius: -8,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: AppColors.primary.withOpacity(isDark ? .12 : .06),
                  blurRadius: 40,
                  spreadRadius: -10,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header row ───────────────────────────────────
                  Row(
                    children: [
                      // Subtle label chip
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * .030,
                          vertical: size.height * .006,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(.20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.scan,
                              size: size.width * .032,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: size.width * .015),
                            AppText(
                              'QR Code',
                              translate: false,
                              fontSize: size.width * .030,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Close button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Get.back();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.all(size.width * .022),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(.08)
                                : Colors.black.withOpacity(.05),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(.08)
                                  : Colors.black.withOpacity(.06),
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: size.width * .044,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * .028),

                  // ── QR container (real, scannable) ────────────────
                  _QrContainer(
                    boundaryKey: _qrBoundaryKey,
                    programLink: widget.programLink,
                    size: qrSize,
                    isDark: isDark,
                  ),

                  SizedBox(height: size.height * .028),

                  // ── Texts ────────────────────────────────────────
                  AppText(
                    "program_qr_title",
                    fontSize: size.width * .052,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.center,
                    color: isDark ? Colors.white : const Color(0xFF1A1D29),
                  ),

                  SizedBox(height: size.height * .010),

                  AppText(
                    "program_qr_subtitle",
                    fontSize: size.width * .035,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? Colors.white.withOpacity(.50)
                        : const Color(0xFF6B7280),
                    textAlign: TextAlign.center,
                    height: 1.45,
                  ),

                  SizedBox(height: size.height * .024),

                  // ── Link field ───────────────────────────────────
                  _LinkField(
                    link: widget.programLink,
                    size: size,
                    isDark: isDark,
                  ),

                  SizedBox(height: size.height * .022),

                  // ── Actions ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Iconsax.document_download,
                          labelKey: "download_qr",
                          filled: true,
                          size: size,
                          isLoading: _isSaving,
                          onTap: _downloadQr,
                        ),
                      ),
                      SizedBox(width: size.width * .03),
                      Expanded(
                        child: _ActionButton(
                          icon: Iconsax.copy,
                          labelKey: "copy_link",
                          filled: false,
                          size: size,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Clipboard.setData(
                              ClipboardData(text: widget.programLink),
                            );
                            Get.snackbar(
                              "",
                              "link_copied".tr,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                              backgroundColor:
                                  AppColors.primary.withOpacity(.92),
                              colorText: Colors.white,
                              borderRadius: 14,
                              icon: const Icon(
                                Iconsax.tick_circle,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Real QR code with decorative frame + inner glow rings ────────────────
class _QrContainer extends StatelessWidget {
  final GlobalKey boundaryKey;
  final String programLink;
  final double size;
  final bool isDark;

  const _QrContainer({
    required this.boundaryKey,
    required this.programLink,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardSize = size * .9;

    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Outer glow ring ─────────────────────────────────────
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(size * .16),
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withOpacity(.12),
                AppColors.primary.withOpacity(.03),
                Colors.transparent,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        // ── Frame card (decorative, holds corner marks) ──────────
        Container(
          width: cardSize*1.3,
          height: cardSize*1.3,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * .14),
            color: isDark
                ? Colors.white.withOpacity(.04)
                : AppColors.primary.withOpacity(.05),
            border: Border.all(
              color: AppColors.primary.withOpacity(.18),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(.14),
                blurRadius: 30,
                spreadRadius: -6,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Corner accent marks (cosmetic, sit in the quiet-zone padding
              // around the white QR card so they never touch the QR data).
              // ..._buildCornerMarks(cardSize, size * .5),

              // ── The actual scannable QR, captured for download ──
              RepaintBoundary(
                key: boundaryKey,
                child: Container(
                  width: cardSize * 1.1,
                  height: cardSize * 1.1,
                  padding: EdgeInsets.all(cardSize * .01),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size * .5),
                  ),
                  child: programLink.isEmpty
                      ? const Center(
                          child: Icon(
                            Iconsax.scan_barcode,
                            color: Color(0xFF1A1D29),
                          ),
                        )
                      : QrImageView(
                          data: programLink,
                          version: QrVersions.auto,
                          gapless: true,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF1A1D29),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF1A1D29),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // List<Widget> _buildCornerMarks(double containerSize, double r) {
  //   const c = AppColors.primary;
  //   const t = 2.4;
  //   final l = containerSize * .15; // mark length
  //   final p = containerSize * .062; // padding from edge
  //   final br = r * 0.42;

  //   Widget mark(AlignmentGeometry align, BorderRadius borderRadius) =>
  //       Positioned.fill(
  //         child: Align(
  //           alignment: align,
  //           child: Padding(
  //             padding: EdgeInsets.all(p),
  //             child: SizedBox(
  //               width: l,
  //               height: l,
  //               child: DecoratedBox(
  //                 decoration: BoxDecoration(
  //                   borderRadius: borderRadius,
  //                   border: Border(
  //                     top: align == Alignment.topLeft ||
  //                             align == Alignment.topRight
  //                         ? const BorderSide(color: c, width: t)
  //                         : BorderSide.none,
  //                     bottom: align == Alignment.bottomLeft ||
  //                             align == Alignment.bottomRight
  //                         ? const BorderSide(color: c, width: t)
  //                         : BorderSide.none,
  //                     left: align == Alignment.topLeft ||
  //                             align == Alignment.bottomLeft
  //                         ? const BorderSide(color: c, width: t)
  //                         : BorderSide.none,
  //                     right: align == Alignment.topRight ||
  //                             align == Alignment.bottomRight
  //                         ? const BorderSide(color: c, width: t)
  //                         : BorderSide.none,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );

  //   return [
  //     mark(Alignment.topLeft, BorderRadius.only(topLeft: Radius.circular(br))),
  //     mark(Alignment.topRight,
  //         BorderRadius.only(topRight: Radius.circular(br))),
  //     mark(Alignment.bottomLeft,
  //         BorderRadius.only(bottomLeft: Radius.circular(br))),
  //     mark(Alignment.bottomRight,
  //         BorderRadius.only(bottomRight: Radius.circular(br))),
  //   ];
  // }
}

// ─── Read-only link field with icon ───────────────────────────────────────────
class _LinkField extends StatelessWidget {
  final String link;
  final Size size;
  final bool isDark;

  const _LinkField({
    required this.link,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .038,
        vertical: size.height * .0125,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(.05)
            : AppColors.primary.withOpacity(.04),
        borderRadius: BorderRadius.circular(size.width * .042),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.08)
              : AppColors.primary.withOpacity(.10),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * .020),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.link_1,
              size: size.width * .038,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: size.width * .026),
          Expanded(
            child: Text(
              link,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: size.width * .032,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                letterSpacing: .2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filled / outlined action button (with optional loading state) ───────────
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String labelKey;
  final bool filled;
  final Size size;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.labelKey,
    required this.filled,
    required this.size,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.94)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isLoading;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _ctrl.forward(),
      onTapUp: disabled
          ? null
          : (_) {
              _ctrl.reverse();
              widget.onTap();
            },
      onTapCancel: disabled ? null : () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Opacity(
          opacity: disabled ? .7 : 1,
          child: Container(
            height: widget.size.height * .065,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size.width * .040),
              gradient: widget.filled
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primary],
                    )
                  : null,
              color: widget.filled ? null : Colors.transparent,
              border: widget.filled
                  ? null
                  : Border.all(
                      color: AppColors.primary,
                      width: 1.4,
                    ),
              boxShadow: widget.filled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(.35),
                        blurRadius: 20,
                        spreadRadius: -4,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: widget.isLoading
                ? Center(
                    child: SizedBox(
                      width: widget.size.width * .042,
                      height: widget.size.width * .042,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.filled
                            ? Colors.white
                            : AppColors.primary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.icon,
                        size: widget.size.width * .042,
                        color: widget.filled ? Colors.white : AppColors.primary,
                      ),
                      SizedBox(width: widget.size.width * .020),
                      AppText(
                        widget.labelKey,
                        fontSize: widget.size.width * .032,
                        fontWeight: FontWeight.w600,
                        color: widget.filled ? Colors.white : AppColors.primary,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}