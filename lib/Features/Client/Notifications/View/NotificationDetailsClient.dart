import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/Notifications/Controllers/ClientNotificationsController.dart';
import 'package:vclub/Features/Client/Notifications/Models/ClientNotificationsModel.dart';

class NotificationDetailsClient extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailsClient({super.key, required this.notification});

  @override
  State<NotificationDetailsClient> createState() =>
      _NotificationDetailsClientState();
}

class _NotificationDetailsClientState
    extends State<NotificationDetailsClient> {
  final NotificationsController controller =
      Get.find<NotificationsController>();

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  Future<void> _markAsRead() async {
    if (!widget.notification.read) {
      await controller.markNotificationAsRead(widget.notification.id);
    }
  }

  // ---------------------------------------------------------------------
  // Style helpers
  // ---------------------------------------------------------------------

  Color get _accent => _accentColor(widget.notification.type);

  Color _accentColor(String type) {
    switch (type) {
      case "campaign":
        return const Color(0xffFF6B6B);
      case "manual":
        return const Color(0xff6C63FF);
      default:
        return const Color(0xff00B8A9);
    }
  }

  IconData get _icon {
    switch (widget.notification.type) {
      case "campaign":
        return Iconsax.notification_bing_copy;
      case "manual":
        return Iconsax.message_copy;
      default:
        return Iconsax.notification_copy;
    }
  }

  String get _typeLabel {
    switch (widget.notification.type) {
      case "campaign":
        return "notification.types.campaign".tr;
      case "manual":
        return "notification.types.manual".tr;
      default:
        return "notification.types.default".tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Get.isDarkMode;
    final isRTL = Get.locale?.languageCode == "ar";

    final bg = isDark ? const Color(0xff0E0F13) : const Color(0xffF7F7FA);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: size.width * .05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * .02),

              // ----- Top bar: back button -----
              FadeSlide(
                delayMs: 80,
                child: _circleButton(
                  context,
                  icon: isRTL
                      ? Iconsax.arrow_right_3_copy
                      : Iconsax.arrow_left_2_copy,
                  onTap: () => Get.back(),
                ),
              ),

              SizedBox(height: size.height * .035),

              // ----- Meta card: type (icon + label) + time -----
              FadeSlide(delayMs: 160, child: _metaCard(context, size)),

              SizedBox(height: size.height * .025),

              // ----- Content card: title + body -----
              FadeSlide(delayMs: 240, child: _contentCard(context, size)),

              SizedBox(height: size.height * .025),

              FadeSlide(delayMs: 320, child: _infoCard(context, size)),

              SizedBox(height: size.height * .04),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Cards
  // ---------------------------------------------------------------------

  BoxDecoration _cardDecoration(BuildContext context) {
    final isDark = Get.isDarkMode;
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(.25)
              : Colors.black.withOpacity(.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _metaCard(BuildContext context, Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .045,
        vertical: size.height * .018,
      ),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _accent.withOpacity(.95),
                  _accent.withOpacity(.65),
                ],
              ),
            ),
            child: Icon(_icon, color: Colors.white, size: 19),
          ),
          SizedBox(width: size.width * .03),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                  _typeLabel,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _accent,
                ),
               SizedBox(height: 6,),
              AppText(
            _formatSmart(widget.notification.createdAt),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(.45),
          ),
            ],
          ),
         
        ],
      ),
    );
  }

  Widget _contentCard(BuildContext context, Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * .055),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            widget.notification.title,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
          SizedBox(height: size.height * .016),
          AppText(
            widget.notification.body,
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(.8),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context, Size size) {
    final rows = <Widget>[
      _infoRow(
        context,
        Iconsax.calendar_1_copy,
        "notification.details.date".tr,
        _formatDate(widget.notification.createdAt),
      ),
      _infoRow(
        context,
        Iconsax.clock_copy,
        "notification.details.time".tr,
        DateFormat("HH:mm").format(widget.notification.createdAt),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * .05),
      decoration: _cardDecoration(context),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              Divider(
                height: 26,
                color: Get.isDarkMode
                    ? Colors.white.withOpacity(.06)
                    : Colors.black.withOpacity(.05),
              ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(.1),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppText(
            title,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(.5),
          ),
        ),
        AppText(value, fontSize: 13.5, fontWeight: FontWeight.w700),
      ],
    );
  }

  Widget _circleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(.3)
                  : Colors.black.withOpacity(.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Date formatting
  // ---------------------------------------------------------------------

  String _formatDate(DateTime date) {
    return DateFormat("d MMM y", Get.locale?.languageCode).format(date);
  }

  /// "Today • 14:32", "Yesterday • 09:10" or "3 Jun • 14:32"
  String _formatSmart(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final diff = today.difference(that).inDays;

    final time = DateFormat("HH:mm").format(date);

    if (diff == 0) return "${"notification.details.today".tr} • $time";
    if (diff == 1) return "${"notification.details.yesterday".tr} • $time";

    return "${DateFormat("d MMM", Get.locale?.languageCode).format(date)} • $time";
  }
}