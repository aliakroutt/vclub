import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/LoyaltyInputField.dart';


class RewardAfterReviewCard extends StatefulWidget {
  const RewardAfterReviewCard({super.key});

  @override
  State<RewardAfterReviewCard> createState() => _RewardAfterReviewCardState();
}

class _RewardAfterReviewCardState extends State<RewardAfterReviewCard> {
  final TextEditingController pointsController = TextEditingController(text: "50");
  final TextEditingController delayController = TextEditingController(text: "7");

  static const _accent = Color(0xFFE8640C);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * 0.042),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── HEADER ─────────────────────────────
          Row(
            children: [
              Container(
                width: size.width * 0.10,
                height: size.width * 0.10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: _accent.withOpacity(0.10),
                ),
                child: Icon(
                  Iconsax.gift,
                  color: _accent,
                  size: size.width * 0.048,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "reward_after_review".tr,
                      fontSize: size.width * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      "reward_after_review_description".tr,
                      fontSize: size.width * 0.028,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.45),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.02),

          /// ── FIELDS ─────────────────────────────
          Column(
  children: [
    LoyaltyInputField(
      label: "points_offered".tr,
      controller: pointsController,
      icon: Iconsax.coin,
      hint: "50",
    ),
    SizedBox(height: size.height * 0.014),
    LoyaltyInputField(
      label: "review_delay_days".tr,
      controller: delayController,
      icon: Iconsax.timer_1,
      hint: "7",
    ),
  ],
),
        ],
      ),
    );
  }
}