import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AuditMeta {
  final IconData icon;
  final Color color;

  const AuditMeta(this.icon, this.color);

  static AuditMeta of(String actionGroup) {
    switch (actionGroup) {
      case 'auth':
        return const AuditMeta(Iconsax.shield_tick, Color(0xFF3D8BFF));
      case 'company':
        return const AuditMeta(Iconsax.building_4, Color(0xFF8B5CF6));
      case 'employee':
      case 'staff':
        return const AuditMeta(Iconsax.people, Color(0xFF1DB876));
      case 'program':
        return const AuditMeta(Iconsax.medal_star, Color(0xFFE2984A));
      case 'reward':
        return const AuditMeta(Iconsax.gift, Color(0xFFE24B4A));
      case 'client':
        return const AuditMeta(Iconsax.user, Color(0xFF14B8A6));
      case 'billing':
        return const AuditMeta(Iconsax.wallet_3, Color(0xFFF2B705));
      case 'settings':
        return const AuditMeta(Iconsax.setting_2, Color(0xFF6B7280));
      default:
        return const AuditMeta(Iconsax.document_text, Color(0xFF6B7280));
    }
  }
}