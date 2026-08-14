import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/ShimmerWrapper.dart';
import 'package:vclub/Features/Merchant/Settings/Controllers/SessionsController.dart';
import 'package:vclub/Features/Merchant/Settings/Models/SessionModel.dart';

class SessionsCard extends StatelessWidget {
  SessionsCard({super.key});

  final controller = Get.put(SessionsController());
  static const _accent = Color(0xFF3D8BFF);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? .22 : .04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: size.width * .105,
                height: size.width * .105,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: _accent.withOpacity(.10)),
                child: Icon(Iconsax.monitor_mobbile, color: _accent, size: size.width * .052),
              ),
              SizedBox(width: size.width * .035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText("active_sessions_title".tr, fontSize: size.width * .042, fontWeight: FontWeight.w700),
                    const SizedBox(height: 2),
                    AppText(
                      "active_sessions_subtitle".tr,
                      fontSize: size.width * .028,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .022),

          Obx(() {
            if (controller.loading.value && !controller.initialLoaded.value) {
              return ShimmerWrapper(
                child: Column(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: 74,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            if (controller.hasError.value && controller.sessions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Iconsax.warning_2, size: 28, color: Colors.redAccent),
                      const SizedBox(height: 10),
                      AppText("failed_load_sessions".tr, fontSize: 12.5, color: Colors.redAccent, textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: controller.refresh,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
                          child: AppText("retry".tr, fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.sessions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: AppText(
                    "no_active_sessions".tr,
                    fontSize: 12.5,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                  ),
                ),
              );
            }

            return Column(
              children: controller.sessions
                  .map((session) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SessionTile(session: session),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionModel session;

  const _SessionTile({required this.session});

  IconData _deviceIcon() {
    final os = (session.os ?? '').toLowerCase();
    if (os.contains('android') || os.contains('ios')) return Iconsax.mobile;
    if (os.contains('mac') || os.contains('windows') || os.contains('linux')) return Iconsax.monitor;
    return Iconsax.global;
  }

  String _relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return "just_now".tr;
    if (diff.inMinutes < 60) return "${diff.inMinutes}${"minutes_short".tr}";
    if (diff.inHours < 24) return "${diff.inHours}${"hours_short".tr}";
    if (diff.inDays < 7) return "${diff.inDays}${"days_short".tr}";

    return DateFormat('d MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SessionsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceLabel = session.isKnownDevice
        ? [session.browser, session.os].where((e) => e != null && e.isNotEmpty).join(' • ')
        : "unknown_device".tr;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
        border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary.withOpacity(.18), AppColors.primary.withOpacity(.08)],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_deviceIcon(), color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(deviceLabel, fontSize: 13, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Iconsax.global, size: 11, color: Colors.grey.withOpacity(.6)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: AppText(
                        session.ipAddress ?? "—",
                        fontSize: 11,
                        overflow: TextOverflow.ellipsis,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 3,
                      width: 3,
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(.4), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      _relativeDate(session.createdAt),
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final revoking = controller.revokingJti.value == session.jti;

            return Material(
              color: Colors.redAccent.withOpacity(.1),
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: revoking ? null : () => controller.revokeSession(session.jti),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: revoking
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: LoadingAnimationWidget.fourRotatingDots(color: Colors.redAccent, size: 16),
                        )
                      : const Icon(Iconsax.logout_1, size: 16, color: Colors.redAccent),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}