import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';
import 'package:vclub/Features/Merchant/Dashboard/Models/MerchantClientModel.dart';

class RecentClientsCard extends StatelessWidget {
  const RecentClientsCard({
    super.key,
    this.onViewAll,
  });

  final VoidCallback? onViewAll;

  static const _accent = Color(0xFF6C5CE7);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = MerchantDashboardController.to;

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.06)
              : Colors.black.withOpacity(.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .22 : .04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                width: size.width * .105,
                height: size.width * .105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _accent.withOpacity(.10),
                ),
                child: Icon(
                  Iconsax.profile_2user,
                  color: _accent,
                  size: size.width * .05,
                ),
              ),

              SizedBox(width: size.width * .035),

              Expanded(
                child: AppText(
                  "recent_clients_merchant".tr,
                  fontSize: size.width * .042,
                  fontWeight: FontWeight.w700,
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onViewAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: AppText(
                    "view_all_merchant".tr,
                    fontSize: size.width * .031,
                    fontWeight: FontWeight.w700,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .022),

          Obx(() {
            // ── ERROR STATE ─────────────────────────────
            if (controller.clientsError.value.isNotEmpty && controller.clients.isEmpty) {
              return _MessageState(
                icon: Iconsax.warning_2,
                iconColor: Colors.redAccent,
                message: controller.clientsError.value,
                actionLabel: "retry_merchant".tr,
                onAction: () => controller.fetchClients(),
                size: size,
                isDark: isDark,
              );
            }

            // ── LOADING / SHIMMER STATE ──────────────────
            if (controller.clientsLoading.value && controller.clients.isEmpty) {
              return Column(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: size.height * .014),
                    child: _ShimmerClientTile(size: size, isDark: isDark),
                  ),
                ),
              );
            }

            // ── EMPTY STATE ──────────────────────────────
            if (controller.clients.isEmpty) {
              return _MessageState(
                icon: Iconsax.profile_2user,
                iconColor: _accent,
                message: "no_recent_clients_merchant".tr,
                size: size,
                isDark: isDark,
              );
            }

            // ── DATA ──────────────────────────────────────
            final displayedClients = controller.clients.take(3).toList();

            return Column(
              children: displayedClients
                  .map(
                    (client) => Padding(
                      padding: EdgeInsets.only(bottom: size.height * .014),
                      child: _ClientTile(client: client),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _ClientTile extends StatelessWidget {
  final MerchantClientModel client;

  const _ClientTile({
    required this.client,
  });

  static const _accent = Color(0xFF6C5CE7);

  String get _fullName {
    final name = "${client.client.firstName} ${client.client.lastName}".trim();
    return name.isNotEmpty ? name : client.client.email;
  }

  String get _initial {
    final first = client.client.firstName.trim();
    if (first.isNotEmpty) return first[0].toUpperCase();
    final email = client.client.email.trim();
    return email.isNotEmpty ? email[0].toUpperCase() : "?";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .035,
        vertical: size.height * .014,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark
            ? Colors.white.withOpacity(.03)
            : Colors.black.withOpacity(.02),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.05)
              : Colors.black.withOpacity(.04),
        ),
      ),
      child: Row(
        children: [
          /// Avatar
          Container(
            width: size.width * .12,
            height: size.width * .12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _accent.withOpacity(.20),
                  _accent.withOpacity(.08),
                ],
              ),
            ),
            child: Center(
              child: AppText(
                _initial,
                fontSize: size.width * .045,
                fontWeight: FontWeight.w800,
                color: _accent,
              ),
            ),
          ),

          SizedBox(width: size.width * .035),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  _fullName,
                  fontWeight: FontWeight.w700,
                  fontSize: size.width * .036,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: size.height * .002),
                AppText(
                  client.client.email,
                  fontWeight: FontWeight.w500,
                  fontSize: size.width * .03,
                  color: isDark
                      ? Colors.white.withOpacity(.45)
                      : Colors.black.withOpacity(.4),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          SizedBox(width: size.width * .02),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.10),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Iconsax.coin,
                  size: 14,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                AppText(
                  "${client.points}",
                  color: Colors.orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── SHIMMER TILE ───────────────────────────────────────────────────────────

class _ShimmerClientTile extends StatefulWidget {
  const _ShimmerClientTile({required this.size, required this.isDark});

  final Size size;
  final bool isDark;

  @override
  State<_ShimmerClientTile> createState() => _ShimmerClientTileState();
}

class _ShimmerClientTileState extends State<_ShimmerClientTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
    required Color baseColor,
    required Color highlightColor,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _controller.value * 3, 0),
                  end: Alignment(0.0 + _controller.value * 3, 0),
                  colors: [baseColor, highlightColor, baseColor],
                  stops: const [0.35, 0.5, 0.65],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final isDark = widget.isDark;
    final baseColor = isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05);
    final highlightColor = isDark ? Colors.white.withOpacity(.14) : Colors.black.withOpacity(.10);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .035,
        vertical: size.height * .014,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.04),
        ),
      ),
      child: Row(
        children: [
          _shimmerBox(
            width: size.width * .12,
            height: size.width * .12,
            radius: size.width * .06,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          SizedBox(width: size.width * .035),
          Expanded(
            child: _shimmerBox(
              width: double.infinity,
              height: 14,
              radius: 6,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
          ),
          SizedBox(width: size.width * .035),
          _shimmerBox(
            width: size.width * .14,
            height: 24,
            radius: 30,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
        ],
      ),
    );
  }
}

// ── MESSAGE STATE (error / empty) ──────────────────────────────────────────

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.size,
    required this.isDark,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String message;
  final Size size;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * .022),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(height: size.height * .014),
          AppText(
            message,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withOpacity(.65) : Colors.black.withOpacity(.55),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: size.height * .014),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: iconColor.withOpacity(.10),
                ),
                child: AppText(
                  actionLabel!,
                  color: iconColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}