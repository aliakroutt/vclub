import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class QRScanCard extends StatelessWidget {
  final VoidCallback ontap ;
  const QRScanCard({super.key, required this.ontap});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final isRTL = Get.locale?.languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: InkWell(
        onTap: ontap,
        child:  Container(
        height: size.height * 0.16,
        margin: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          // soft glass background
          color: Theme.of(context).cardColor,

          // dotted border effect using Border.all + dash simulation trick
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.18)
                : Colors.black.withOpacity(0.12),
            width: 1.2,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: CustomPaint(
          painter: _DottedBorderPainter(
            color: isDark
                ? Colors.white.withOpacity(0.25)
                : Colors.black.withOpacity(0.25),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.scan_barcode,
                  size: 34,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                const SizedBox(height: 10),

                AppText(
                  "scan_qr_client".tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
class _DottedBorderPainter extends CustomPainter {
  final Color color;

  _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 6;
    const dashSpace = 4;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(20),
        ),
      );

    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}