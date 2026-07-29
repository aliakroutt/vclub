import 'package:intl/intl.dart';
import 'package:get/get.dart';

class DateFormatter {
  DateFormatter._();

  /// MAIN FUNCTION (AUTO LANGUAGE)
  static String format(DateTime? date) {
    if (date == null) return "";

    final lang = Get.locale?.languageCode ?? "en";

    switch (lang) {
      case "fr":
        return _formatFrench(date);
      case "ar":
        return _formatArabic(date);
      default:
        return _formatEnglish(date);
    }
  }

  //==================================================
  // ENGLISH FORMAT
  // Example: 12 July 1997
  //==================================================
  static String _formatEnglish(DateTime date) {
    return DateFormat("dd MMMM yyyy", "en").format(date);
  }

  //==================================================
  // FRENCH FORMAT
  // Example: 12 juillet 1997
  //==================================================
  static String _formatFrench(DateTime date) {
    return DateFormat("dd MMMM yyyy", "fr").format(date);
  }

  //==================================================
  // ARABIC FORMAT
  // Example: 12 يوليو 1997
  //==================================================
  static String _formatArabic(DateTime date) {
    return DateFormat("dd MMMM yyyy", "ar").format(date);
  }

  //==================================================
  // OPTIONAL: FULL FORMAT (with time)
  //==================================================
  static String formatWithTime(DateTime? date) {
    if (date == null) return "";

    final lang = Get.locale?.languageCode ?? "en";

    switch (lang) {
      case "fr":
        return DateFormat("dd MMM yyyy • HH:mm", "fr").format(date);
      case "ar":
        return DateFormat("yyyy/MM/dd • HH:mm", "ar").format(date);
      default:
        return DateFormat("dd MMM yyyy • hh:mm a", "en").format(date);
    }
  }

  //==================================================
  // OPTIONAL: SHORT FORMAT
  //==================================================
  static String formatShort(DateTime? date) {
    if (date == null) return "";

    return DateFormat("dd/MM/yyyy").format(date);
  }
}