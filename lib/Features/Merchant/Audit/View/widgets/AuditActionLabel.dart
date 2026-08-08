import 'package:get/get.dart';

class AuditActionLabel {
  AuditActionLabel._();

  static String of(String action) {
    if (action.isEmpty) return "audit_action_default".tr;

    final key = "audit_action_${action.replaceAll('.', '_')}";
    final translated = key.tr;

    // GetX returns the key itself when no translation is found.
    if (translated != key) return translated;

    return _fallbackFormat(action);
  }

  static String _fallbackFormat(String action) {
    final parts = action.split(RegExp(r'[._]'));
    final formatted = parts
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
    return formatted.isEmpty ? action : formatted;
  }
}