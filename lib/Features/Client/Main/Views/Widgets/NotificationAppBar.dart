// ─────────────────────────────────────────────────────────────
//  Notification button with red badge
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Client/Notifications/Controllers/ClientNotificationsController.dart';

class NotificationButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const NotificationButton({
    required this.isDark,
    required this.onTap,
  });

  @override
  State<NotificationButton> createState() => NotificationButtonState();
}

class NotificationButtonState extends State<NotificationButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifController = Get.find<NotificationsController>();

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(widget.isDark ? 0.15 : 0.09),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.primary.withOpacity(widget.isDark ? 0.30 : 0.22),
                width: 0.5,
              ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                Iconsax.notification_copy,
                size: 19,
                color: AppColors.primary
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Obx(() {
                  final count = notifController.unread.value;
                  if (count <= 0) return const SizedBox.shrink();
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.isDark ? Colors.black : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}