import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Models/MerchantNotificationsSendModel.dart';

class SentNotificationCard extends StatefulWidget {
  final MerchantNotificationModel notification;
  final int index;

  const SentNotificationCard({
    super.key,
    required this.notification,
    this.index = 0,
  });

  @override
  State<SentNotificationCard> createState() => _SentNotificationCardState();
}

class _SentNotificationCardState extends State<SentNotificationCard> {
  bool _expanded = false;

  String _relativeDate(DateTime? date) {
    if (date == null) return "";
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return "just_now".tr;
    if (diff.inMinutes < 60) return "${diff.inMinutes}${"minutes_short".tr}";
    if (diff.inHours < 24) return "${diff.inHours}${"hours_short".tr}";
    if (diff.inDays < 7) return "${diff.inDays}${"days_short".tr}";

    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notification = widget.notification;

    return FadeSlide(
      delayMs: (widget.index * 60).clamp(0, 420),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? const Color(0xFF1C1F26) : Colors.white,
          // border: Border.all(
          //   color: _expanded
          //       ? AppColors.primary.withOpacity(.35)
          //       : (isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04)),
          // ),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              spreadRadius: -8,
              offset: const Offset(0, 8),
              color: isDark ? Colors.black.withOpacity(.4) : AppColors.primary.withOpacity(.07),
            ),
          ],
        ),
        child: Material(
          // color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.primary.withOpacity(.6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.notification_bing, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: AppText(
                                      notification.type.toUpperCase(),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                // if (!notification.read) ...[
                                //   const SizedBox(width: 6),
                                //   Container(
                                //     height: 6,
                                //     width: 6,
                                //     decoration: const BoxDecoration(
                                //       color: Colors.redAccent,
                                //       shape: BoxShape.circle,
                                //     ),
                                //   ),
                                // ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            AppText(
                              _relativeDate(notification.createdAt),
                              fontSize: 11,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                            ),
                          ],
                        ),
                      ),
                      // AnimatedRotation(
                      //   turns: _expanded ? 0.5 : 0,
                      //   duration: const Duration(milliseconds: 280),
                      //   child: Icon(
                      //     Iconsax.arrow_down_1,
                      //     size: 16,
                      //     color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.4),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          child: Text(
                            notification.title,
                            maxLines: _expanded ? null : 1,
                            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65),
                          ),
                          child: Text(
                            notification.body,
                            maxLines: _expanded ? null : 1,
                            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.primary.withOpacity(.1),
                        child: Icon(Iconsax.user, size: 11, color: AppColors.primary),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: AppText(
                          notification.client?.fullName ?? "",
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}