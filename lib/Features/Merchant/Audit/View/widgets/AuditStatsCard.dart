import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Audit/Controllers/MerchantAuditController.dart';

class AuditStatsCard extends StatelessWidget {
  const AuditStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantAuditController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(.78)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Iconsax.document_text_1, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 11),
          AppText(
            "total_events_label".tr,
            fontSize: 12,
            color: Colors.white.withOpacity(.88),
            fontWeight: FontWeight.w600,
          ),
          const Spacer(),
          Obx(() {
            final count = controller.totalItems.value;
            return AppText(
              "$count",
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            );
          }),
        ],
      ),
    );
  }
}