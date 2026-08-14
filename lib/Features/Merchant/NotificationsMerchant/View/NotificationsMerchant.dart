import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/MerchantNotificationsListController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationDetailsMerchant.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/Widgets/MerchantNotificationCard.dart';

class NotificationsInboxMerchant extends StatefulWidget {
  const NotificationsInboxMerchant({super.key});

  @override
  State<NotificationsInboxMerchant> createState() => _NotificationsInboxMerchantState();
}

class _NotificationsInboxMerchantState extends State<NotificationsInboxMerchant> {
  final MerchantNotificationsListController notifcontroller =
      Get.find<MerchantNotificationsListController>();

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifcontroller.fetchNotifications();
      scrollController.addListener(() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 250) {
          notifcontroller.loadMoreNotifications();
        }
      });

      if (!notifcontroller.initialLoaded.value) {
        notifcontroller.fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == "ar";

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── FIXED HEADER (never scrolls) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * .02),
                  FadeSlide(
                    delayMs: 80,
                    child: _circleButton(
                      context,
                      icon: isRTL ? Iconsax.arrow_right_3_copy : Iconsax.arrow_left_2_copy,
                      onTap: () => Get.back(),
                    ),
                  ),
                  SizedBox(height: size.height * .02),
                  _buildHeader(context, size, notifcontroller),
                  SizedBox(height: size.height * .02),
                ],
              ),
            ),

            // ── SCROLLABLE LIST (only this scrolls) ──
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await notifcontroller.fetchNotifications();
                },
                child: Obx(() {
                  if (notifcontroller.notificationsLoading.value) {
                    return Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: AppColors.primary,
                        size: 52,
                      ),
                    );
                  }

                  if (notifcontroller.notifications.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [_emptyState()],
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: notifcontroller.notifications.length +
                        (notifcontroller.loadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == notifcontroller.notifications.length) {
                        return Obx(() {
                          if (!notifcontroller.loadingMore.value) {
                            return const SizedBox();
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: LoadingAnimationWidget.fourRotatingDots(
                                color: AppColors.primary,
                                size: 40,
                              ),
                            ),
                          );
                        });
                      }

                      final notification = notifcontroller.notifications[index];

                      return FadeSlide(
                        delayMs: 100 + (index * 50),
                        child: MerchantNotificationCard(
                          notification: notification,
                          onTap: () {
                            AppNavigator.to(
                              NotificationDetailsMerchant(notification: notification),
                            );
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: size.height * 0.14),

        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size.width * 0.34,
                height: size.width * 0.34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.14),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              Container(
                width: size.width * 0.22,
                height: size.width * 0.22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.18),
                      AppColors.primary.withOpacity(0.06),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Iconsax.notification_bing,
                  size: size.width * 0.09,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: size.height * 0.025),

        AppText(
          "notification.empty_title".tr,
          fontSize: size.width * 0.042,
          fontWeight: FontWeight.w700,
        ),

        SizedBox(height: size.height * 0.008),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.12),
          child: AppText(
            "notification.empty_subtitle".tr,
            fontSize: size.width * 0.032,
            color: Colors.grey.shade500,
            textAlign: TextAlign.center,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Size size,
    MerchantNotificationsListController notifcontroller,
  ) {
    return FadeSlide(
      delayMs: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: size.width * .14,
                height: size.width * .14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Iconsax.notification_bing_copy,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              SizedBox(width: size.width * .04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "notifications".tr,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => AppText(
                        "unread_notifications".trParams({
                          "count": notifcontroller.unread.value.toString(),
                        }),
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const MarkAllReadButtonMerchant(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Mark-all-as-read button — premium animated version (Merchant)
// ─────────────────────────────────────────────────────────────

class MarkAllReadButtonMerchant extends StatefulWidget {
  const MarkAllReadButtonMerchant({super.key});

  @override
  State<MarkAllReadButtonMerchant> createState() => _MarkAllReadButtonMerchantState();
}

enum _ButtonState { idle, loading, success }

class _MarkAllReadButtonMerchantState extends State<MarkAllReadButtonMerchant>
    with TickerProviderStateMixin {
  final notifcontroller = Get.find<MerchantNotificationsListController>();

  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  late final AnimationController _glowCtrl;
  late final Animation<double> _glowScale;

  _ButtonState _state = _ButtonState.idle;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _glowScale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_state != _ButtonState.idle) return;

    setState(() => _state = _ButtonState.loading);

    try {
      await notifcontroller.markAllNotificationsAsRead();
      if (!mounted) return;
      setState(() => _state = _ButtonState.success);

      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _state = _ButtonState.idle);
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _ButtonState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _state != _ButtonState.idle;

    return GestureDetector(
      onTapDown: isBusy ? null : (_) => _pressCtrl.forward(),
      onTapUp: isBusy
          ? null
          : (_) async {
              await _pressCtrl.reverse();
              _handleTap();
            },
      onTapCancel: isBusy ? null : () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(
                      _state == _ButtonState.loading
                          ? 0.25 + (_glowScale.value - 0.85) * 0.3
                          : 0.20,
                    ),
                    blurRadius: _state == _ButtonState.loading
                        ? 14 * _glowScale.value
                        : 10,
                    spreadRadius: _state == _ButtonState.loading ? 1 : 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case _ButtonState.loading:
        return const SizedBox(
          key: ValueKey("loader"),
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        );

      case _ButtonState.success:
        return Row(
          key: const ValueKey("success"),
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.tick_circle, size: 17, color: Colors.white),
            const SizedBox(width: 6),
            AppText(
              "all_caught_up".tr,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ],
        );

      case _ButtonState.idle:
        return Row(
          key: const ValueKey("button"),
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.tick_circle_copy, size: 17, color: Colors.white),
            const SizedBox(width: 6),
            AppText(
              "mark_all_as_read".tr,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ],
        );
    }
  }
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
            color: isDark ? Colors.black.withOpacity(.3) : Colors.black.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 18),
    ),
  );
}