import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Models/MerchantNotificationsModel.dart';


class MerchantNotificationCard extends StatelessWidget {
  final MerchantNotificationModel notification;
  final VoidCallback? onTap;

  const MerchantNotificationCard({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isUnread = !notification.read;

    final accent = _accentColor(notification.type);

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(20),

        splashColor: accent.withOpacity(.06),

        highlightColor: accent.withOpacity(.03),

        child: Padding(
          padding: EdgeInsets.only(bottom: size.height * .016),
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: size.width * .00,
              vertical: size.height * .00,
            ),

            padding: EdgeInsets.symmetric(
              horizontal: size.width * .04,
              vertical: size.height * .016,
            ),

            decoration: BoxDecoration(
              color: isUnread ? accent.withOpacity(isDark ? .2 : .1) : Get.theme.cardColor,

              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(.06)
                    : Colors.black.withOpacity(.045),

                width: 1,
              ),
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                _NotificationIcon(
                  type: notification.type,

                  accent: accent,

                  size: size.width * .115,
                ),

                SizedBox(width: size.width * .032),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppText(
                              notification.title,

                              fontSize: 14.5,

                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,

                              maxLines: 1,

                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(width: size.width * .02),

                          if (isUnread)
                            Container(
                              width: 7,
                              height: 7,

                              margin: const EdgeInsetsDirectional.only(end: 6),

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent,
                              ),
                            ),

                          AppText(
                            _formatTime(notification.createdAt),

                            fontSize: 11,

                            fontWeight: FontWeight.w500,

                            color: Theme.of(
                              context,
                            ).textTheme.bodySmall?.color?.withOpacity(.4),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * .005),

                      AppText(
                        notification.body,

                        fontSize: 12.5,

                        fontWeight: FontWeight.w400,

                        color: Theme.of(context).textTheme.bodySmall?.color
                            ?.withOpacity(isUnread ? .68 : .5),

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        height: 1.35,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _accentColor(String type) {
    switch (type) {
      case "campaign":
        return AppColors.primary;

      case "manual":
        return AppColors.primary;

      default:
        return AppColors.primary;
    }
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) {
      return "time.just_now".tr;
    }

    if (diff.inHours < 1) {
      return "time.minutes_ago".trParams({"count": diff.inMinutes.toString()});
    }

    if (diff.inDays < 1) {
      return "time.hours_ago".trParams({"count": diff.inHours.toString()});
    }

    if (diff.inDays == 1) {
      return "time.yesterday".tr;
    }

    if (diff.inDays < 7) {
      return "time.days_ago".trParams({"count": diff.inDays.toString()});
    }

    return "time.weeks_ago".trParams({"count": (diff.inDays ~/ 7).toString()});
  }
}

class _NotificationIcon extends StatelessWidget {
  final String type;
  final Color accent;
  final double size;

  const _NotificationIcon({
    required this.type,
    required this.accent,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: accent.withOpacity(.12),
      ),

      child: Icon(_icon(), color: accent, size: size * .48),
    );
  }

  IconData _icon() {
    switch (type) {
      case "campaign":
        return Iconsax.notification_bing_copy;

      case "manual":
        return Iconsax.notification_bing_copy;

      default:
        return Iconsax.notification_bing_copy;
    }
  }
}