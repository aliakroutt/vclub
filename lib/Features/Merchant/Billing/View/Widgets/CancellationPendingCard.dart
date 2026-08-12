import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/SmsAddonController.dart';

class CancellationPendingCard extends StatelessWidget {
  const CancellationPendingCard({super.key, required this.subscriptionEndsAt});

  final DateTime? subscriptionEndsAt;

  static const _color = Color(0xFFFFA53E);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SmsAddonController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final endDateLabel = subscriptionEndsAt != null
        ? DateFormat('d MMM yyyy').format(subscriptionEndsAt!)
        : "—";

    Future<void> handleReactivate() async {
      await controller.reactivateSubscription();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        border: Border.all(color: _color.withOpacity(.3)),
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_color, _color.withOpacity(.7)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: _color.withOpacity(.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Iconsax.warning_2,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "cancellation_pending_title".tr,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      "${"cancellation_pending_subtitle".tr} $endDateLabel. ${"cancellation_pending_note".tr}",
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(.65),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: Obx(() {
              final loading = controller.isReactivating.value;

              return Material(
                color: _color,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: loading ? null : handleReactivate,
                  child: Center(
                    child: loading
                        ? LoadingAnimationWidget.fourRotatingDots(
                            color: Colors.white,
                            size: 24,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Iconsax.refresh_circle,
                                size: 17,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              AppText(
                                "reactivate_subscription".tr,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ],
                          ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
