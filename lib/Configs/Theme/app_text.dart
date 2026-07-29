import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatelessWidget {
  final String text;

  final bool translate;

  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  final double? height;
  final double? letterSpacing;

  final TextDecoration? decoration;
  final FontStyle? fontStyle;

  const AppText(
    this.text, {
    super.key,
    this.translate = true,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.height = 1.0,
    this.letterSpacing = 0,
    this.decoration,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Text(
      translate ? text.tr : text,
      textAlign:
          textAlign ??
          (isArabic ? TextAlign.right : TextAlign.left),
      textDirection:
          isArabic ? TextDirection.rtl : TextDirection.ltr,
      overflow: overflow,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
        fontStyle: fontStyle,
      ),
    );
  }
}