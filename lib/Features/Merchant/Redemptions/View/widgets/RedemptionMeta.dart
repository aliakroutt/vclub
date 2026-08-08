import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Features/Merchant/Redemptions/Models/MerchantRedemptionModel.dart';

class RedemptionMeta {
  final IconData icon;
  final Color color;
  final String labelKey;

  const RedemptionMeta(this.icon, this.color, this.labelKey);

  static RedemptionMeta of(RedemptionStatus status) {
    switch (status) {
      case RedemptionStatus.fulfilled:
        return const RedemptionMeta(Iconsax.tick_circle, Color(0xFF1DB876), "redemption_status_fulfilled");
      case RedemptionStatus.canceled:
        return const RedemptionMeta(Iconsax.close_circle, Color(0xFFE24B4A), "redemption_status_canceled");
      case RedemptionStatus.unknown:
        return const RedemptionMeta(Iconsax.gift, Color(0xFF6B7280), "redemption_status_unknown");
    }
  }
}