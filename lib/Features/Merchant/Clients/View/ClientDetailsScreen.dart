import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Clients/Controllers/ClientDetailsController.dart';
import 'package:vclub/Features/Merchant/Clients/Models/ClientModel.dart';
import 'package:vclub/Features/Merchant/Clients/View/Widgets/ActivityEmptyState.dart';
import 'package:vclub/Features/Merchant/Clients/View/Widgets/ActivityErrorState.dart';
import 'package:vclub/Features/Merchant/Clients/View/Widgets/ClientDetailShimmer.dart';

List<Color> _levelGradient(String level) {
  switch (level.toLowerCase()) {
    case 'bronze':   return [const Color(0xFFB87333), const Color(0xFF8B5E27)];
    case 'silver':   return [const Color(0xFFCDD4DB), const Color(0xFF8F98A3)];
    case 'gold':     return [const Color(0xFFE8B200), const Color(0xFFC48500)];
    case 'platinum': return [const Color(0xFF7B9FFF), const Color(0xFF3D5FD9)];
    case 'vip':      return [const Color(0xFFD070F0), const Color(0xFF8E24AA)];
    default:         return [AppColors.primary, AppColors.primary.withOpacity(.6)];
  }
}

class ClientDetailScreen extends StatefulWidget {
  final ClientModel client;
  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late final String _tag;
  late final ClientDetailsController controller;

  @override
  void initState() {
    super.initState();
    _tag = widget.client.membershipId;
    controller = Get.put(ClientDetailsController(widget.client), tag: _tag);
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    Get.delete<ClientDetailsController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRTL = Get.locale?.languageCode == 'ar';
    return Scaffold(
      backgroundColor: cs.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: cs.background,
            elevation: 0,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _circleButton(
                      context,
                      icon: isRTL
                          ? Iconsax.arrow_right_3_copy
                          : Iconsax.arrow_left_2_copy,
                      onTap: () => Get.back(),
                    )
            ),
           
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ClientDetailShimmer();
                }

                if (controller.hasError.value) {
                  return ActivityErrorState(onRetry: controller.fetchDetails);
                }

                final client = controller.client.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FadeSlide(
                      controller: _ctrl,
                      interval: const Interval(0, .5, curve: Curves.easeOut),
                      child: _HeroCard(client: client),
                    ),
                    _FadeSlide(
                      controller: _ctrl,
                      interval: const Interval(.2, .65, curve: Curves.easeOut),
                      child: _InfoGrid(client: widget.client),
                    ),
                    _FadeSlide(
                      controller: _ctrl,
                      interval: const Interval(.35, .7, curve: Curves.easeOut),
                      child: _ActivityHeader(count: client.history.length),
                    ),
                    const SizedBox(height: 12),

                    if (client.history.isEmpty)
                      const ActivityEmptyState()
                    else
                      ...client.history.asMap().entries.map((e) => _FadeSlide(
                            controller: _ctrl,
                            interval: Interval(
                              (0.45 + e.key * 0.05).clamp(0.0, 1.0),
                              (0.70 + e.key * 0.05).clamp(0.0, 1.0),
                              curve: Curves.easeOut,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _ActivityRow(item: e.value),
                            ),
                          )),

                    const SizedBox(height: 30),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Card ─────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final ClientModel client;
  const _HeroCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final textBody = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    final textSub = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final gradient = _levelGradient(client.level);
    final divider = Theme.of(context).dividerColor.withOpacity(.10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .35 : .08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .20 : .04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
              ),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(shape: BoxShape.circle, color: cs.surface),
                alignment: Alignment.center,
                child: AppText(client.initials, fontSize: 26, fontWeight: FontWeight.w700, color: textBody),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: gradient.first.withOpacity(.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              client.level.toUpperCase(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: gradient.first, letterSpacing: 1.4),
            ),
          ),
          const SizedBox(height: 10),
          AppText(client.fullName, fontSize: 22, fontWeight: FontWeight.w700, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          _MetaLine(icon: Iconsax.sms, label: client.email, color: textSub),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MetaLine(icon: Iconsax.call, label: client.phone, color: textSub),
              const SizedBox(width: 14),
              _MetaLine(icon: Iconsax.cake, label: client.birthdayFormatted, color: textSub),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: divider, height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _StatPill(icon: Iconsax.coin, value: client.points.toString(), labelKey: "points")),
              Container(width: 1, height: 36, color: divider),
              Expanded(child: _StatPill(icon: Iconsax.scan, value: client.visits.toString(), labelKey: "visits")),
              Container(width: 1, height: 36, color: divider),
              Expanded(child: _StatPill(icon: Iconsax.gift, value: client.rewards.toString(), labelKey: "rewards")),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaLine({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(child: AppText(label, fontSize: 12, color: color, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      );
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value, labelKey;
  const _StatPill({required this.icon, required this.value, required this.labelKey});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(height: 6),
          AppText(value, fontSize: 20, fontWeight: FontWeight.w700),
          const SizedBox(height: 2),
          AppText(labelKey, fontSize: 11),
        ],
      );
}

// ─── Info Grid ───────────────────────────────────────────────────────────────
class _InfoGrid extends StatelessWidget {
  final ClientModel client;
  const _InfoGrid({required this.client});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _InfoTile(icon: Iconsax.calendar_1, labelKey: "member_since", value: client.memberSince),
          _InfoTile(icon: Iconsax.clock, labelKey: "last_visit", value: client.lastVisit),
          _InfoTile(icon: Iconsax.wallet_3, labelKey: "cashback", value: client.cashbackFormatted),
          _InfoTile(icon: Iconsax.star_1, labelKey: "stamps", value: client.stamps.toString()),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String labelKey, value;
  const _InfoTile({required this.icon, required this.labelKey, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .35 : .08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .18 : .03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.1),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(labelKey, fontSize: 10 , color: AppColors.primary,),
                const SizedBox(height: 2),
                AppText(value, fontSize: 13, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Activity Header ───────────────────────────────────────────────────────
class _ActivityHeader extends StatelessWidget {
  final int count;
  const _ActivityHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerColor.withOpacity(.10);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText("activity_history", fontSize: 15, fontWeight: FontWeight.w600),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: border, width: 1)),
            child: AppText('$count ${'events'.tr}', fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── Activity Row ───────────────────────────────────────────────────────────
class _ActivityRow extends StatelessWidget {
  final ActivityItem item;
  const _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPos = item.points >= 0;
    const green = Color(0xFF1DB876);
    const red = Color(0xFFE24B4A);
    final ptColor = isPos ? green : red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? .18 : .04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: item.iconBg, borderRadius: BorderRadius.circular(11)),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 16, color: item.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(item.name, fontSize: 13, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                AppText(item.dateFormatted, fontSize: 11),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: ptColor.withOpacity(.10), borderRadius: BorderRadius.circular(20)),
            child: AppText("${isPos ? '+' : ''}${item.points}", fontSize: 13, fontWeight: FontWeight.w700, color: ptColor),
          ),
        ],
      ),
    );
  }
}

// ─── Shared animation wrapper ────────────────────────────────────────────────
class _FadeSlide extends StatelessWidget {
  final AnimationController controller;
  final Interval interval;
  final Widget child;
  const _FadeSlide({required this.controller, required this.interval, required this.child});

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(parent: controller, curve: interval);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, .04), end: Offset.zero).animate(anim),
        child: child,
      ),
    );
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
              color: isDark
                  ? Colors.black.withOpacity(.1)
                  : Colors.black.withOpacity(.1),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }