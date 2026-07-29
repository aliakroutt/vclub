import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/Cards/Controllers/ClientCradsController.dart';
import 'package:vclub/Features/Client/QRScanner/ProgramClientApi.dart';
import 'package:vclub/Features/Client/QRScanner/View/JoinClubsDialog.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with TickerProviderStateMixin {
  final cards_controller = ClientCardsController.to;
  final MobileScannerController controller = MobileScannerController();
  bool isFlashOn = false;
  bool isHandled = false;
  bool isProcessing = false;
 
  late final AnimationController _scanCtrl;
  late final Animation<double> _scanAnim;
 
  static const double _frameSize = 260;
 
  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
 
    _scanAnim = CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut);
  }
 
  @override
  void dispose() {
    _scanCtrl.dispose();
    controller.dispose();
    super.dispose();
  }
 
  void _onDetect(BarcodeCapture capture) {
    if (isHandled || isProcessing) return;
    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null) return;
 
    isHandled = true;
    _handleQrCode(rawValue);
  }
 
  Future<void> _handleQrCode(String rawValue) async {
    setState(() => isProcessing = true);
 
    try {
      final joinData = ProgramApiClient.extractJoinData(rawValue);
      if (joinData == null) {
        _failAndClose("invalid_qr_code".tr);
        return;
      }
 
      final result = await ProgramApiClient.joinProgram(
        clubSlug: joinData.clubSlug,
        programSlug: joinData.programSlug,
      );
 
      if (result.joined) {
        // Refresh the client's list of cards now that a new
        // membership was created, before leaving the scanner.
        await cards_controller.fetchCards();
 
        if (!mounted) return;
        Get.back(result: result);
        JoinClubDialogs.showSuccess();
      } else {
        _failAndClose(
          result.message ?? "join_failed_generic".tr,
        );
      }
    } catch (e) {
      _failAndClose(ProgramApiClient.extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }
 
  void _failAndClose(String message) {
    if (mounted) Get.back();
    JoinClubDialogs.showError(message);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            /// CAMERA VIEW
            MobileScanner(controller: controller, onDetect: _onDetect),

            /// CUTOUT OVERLAY (real focus effect, not a flat dim layer)
            CustomPaint(
              size: Size(size.width, size.height),
              painter: _CutoutPainter(frameSize: _frameSize),
            ),

            /// SCAN FRAME + ANIMATED LINE + CORNERS
            Center(
              child: SizedBox(
                width: _frameSize,
                height: _frameSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),

                    /// ANIMATED SCAN LINE
                    AnimatedBuilder(
                      animation: _scanAnim,
                      builder: (context, child) {
                        return Positioned(
                          top: 6 + _scanAnim.value * (_frameSize - 12),
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0),
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.7),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    _corner(top: -2, left: -2, isTop: true, isLeft: true),
                    _corner(top: -2, right: -2, isTop: true, isLeft: false),
                    _corner(bottom: -2, left: -2, isTop: false, isLeft: true),
                    _corner(bottom: -2, right: -2, isTop: false, isLeft: false),
                  ],
                ),
              ),
            ),

            /// TOP BAR — frosted glass
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  _iconButton(
                    icon: Iconsax.arrow_left_2,
                    onTap: () => Get.back(),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: AppText(
                          "scan_qr",
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _iconButton(
                    icon: isFlashOn ? Iconsax.flash_1 : Iconsax.flash,
                    isActive: isFlashOn,
                    onTap: () {
                      setState(() {
                        isFlashOn = !isFlashOn;
                        controller.toggleTorch();
                      });
                    },
                  ),
                ],
              ),
            ),

            /// BOTTOM INFO CARD — frosted glass + gradient ring
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.15),
                          ),
                          child: Icon(
                            Iconsax.scan_barcode,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppText(
                          "place_qr_inside_frame",
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          "auto_scan",
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// PROCESSING OVERLAY — shown while the join/cards calls run
            if (isProcessing)
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      color: Colors.black.withOpacity(0.45),
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.85, end: 1.0),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutBack,
                          builder: (context, scale, child) {
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 36,
                                  vertical: 28,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.14),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    LoadingAnimationWidget.fourRotatingDots(
                                      color: AppColors.primary,
                                      size: 52,
                                    ),
                                    const SizedBox(height: 18),
                                    AppText(
                                      "joining_club",
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withOpacity(0.25)
                  : Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withOpacity(0.5)
                    : Colors.white.withOpacity(0.12),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _corner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(20) : Radius.zero,
            topRight: isTop && !isLeft
                ? const Radius.circular(20)
                : Radius.zero,
            bottomLeft: !isTop && isLeft
                ? const Radius.circular(20)
                : Radius.zero,
            bottomRight: !isTop && !isLeft
                ? const Radius.circular(20)
                : Radius.zero,
          ),
          border: Border(
            top: isTop
                ? BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            bottom: !isTop
                ? BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            left: isLeft
                ? BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
            right: !isLeft
                ? BorderSide(color: AppColors.primary, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// Paints a dark overlay with a transparent rounded-square cutout
/// in the center, so only the scan frame area is fully visible.
class _CutoutPainter extends CustomPainter {
  final double frameSize;

  _CutoutPainter({required this.frameSize});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.6);

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameSize,
      height: frameSize,
    );
    final cutoutRRect = RRect.fromRectAndRadius(
      cutoutRect,
      const Radius.circular(24),
    );

    final path = Path()
      ..addRect(fullRect)
      ..addRRect(cutoutRRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant _CutoutPainter oldDelegate) => false;
}
