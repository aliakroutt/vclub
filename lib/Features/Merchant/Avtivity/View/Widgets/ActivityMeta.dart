import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ActivityMeta {
  final IconData icon;
  final Color color;
  final String labelKey;

  const ActivityMeta(this.icon, this.color, this.labelKey);

  static ActivityMeta of(String action) {
    switch (action) {
      case 'join':
        return const ActivityMeta(Iconsax.user_add, Color(0xFF8B5CF6), "activity_action_join");
      case 'add_points':
        return const ActivityMeta(Iconsax.coin, Color(0xFF1DB876), "activity_action_add_points");
      case 'add_stamp':
        return const ActivityMeta(Iconsax.star_1, Color(0xFF3D8BFF), "activity_action_add_stamp");
      case 'cashback':
        return const ActivityMeta(Iconsax.wallet_money, Color(0xFF14B8A6), "activity_action_cashback");
      case 'redeem_reward':
        return const ActivityMeta(Iconsax.gift, Color(0xFFE24B4A), "activity_action_redeem_reward");
      case 'validate_reward':
        return const ActivityMeta(Iconsax.tick_circle, Color(0xFFE2984A), "activity_action_validate_reward");
      case 'review_reward':
        return const ActivityMeta(Iconsax.star, Color(0xFFF2B705), "activity_action_review_reward");
      case 'stamp_reward':
        return const ActivityMeta(Iconsax.gift, Color(0xFFE24B4A), "activity_action_stamp_reward");
      case 'points_reward':
        return const ActivityMeta(Iconsax.gift, Color(0xFFE24B4A), "activity_action_points_reward");
      default:
        return const ActivityMeta(Iconsax.activity, Color(0xFF6B7280), "activity_action_default");
    }
  }
}