import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class SentNotificationsErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const SentNotificationsErrorState({
    super.key,
    this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 120,),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.redAccent.withOpacity(.16),
                      Colors.redAccent.withOpacity(.04),
                    ],
                  ),
                ),
                child: const Icon(Iconsax.warning_2, size: 40, color: Colors.redAccent),
              ),
              const SizedBox(height: 24),
              AppText(
                "something_went_wrong".tr,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              AppText(
                (message == null || message!.isEmpty)
                    ? "failed_load_notifications".tr
                    : message!,
                fontSize: 13.5,
                textAlign: TextAlign.center,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.refresh, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      AppText("retry".tr, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}