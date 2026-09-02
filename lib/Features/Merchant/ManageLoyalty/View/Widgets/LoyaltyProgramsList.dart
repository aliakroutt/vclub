import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/MerchantProgramsController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/LoyaltyProgramModel.dart'
    show ProgramMode;
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramsModel.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/ProgramClients.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/ProgramDetails.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/ProgramFreezeDialog.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/ProgramModelDisplayExtension.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/QRDialog.dart';

class ProgramsListCard extends StatefulWidget {
  const ProgramsListCard({super.key});

  @override
  State<ProgramsListCard> createState() => _ProgramsListCardState();
}

class _ProgramsListCardState extends State<ProgramsListCard> {
  final ScrollController _scrollController = ScrollController();
  final MerchantProgramsController controller = MerchantProgramsController.to;

  @override
  void initState() {
    super.initState();
    if (!controller.initialLoaded.value) {
      controller.fetchPrograms();
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  static IconData _icon(ProgramMode mode) => switch (mode) {
    ProgramMode.points => Iconsax.coin,
    ProgramMode.stamps => Iconsax.ticket_star,
    ProgramMode.cashback => Iconsax.money,
  };

  static String _modeKey(ProgramMode mode) => switch (mode) {
    ProgramMode.points => "program_mode_points",
    ProgramMode.stamps => "program_mode_stamps",
    ProgramMode.cashback => "program_mode_cashback",
  };

  static Color _color(ProgramMode mode) => switch (mode) {
    ProgramMode.points => const Color(0xFF7C6FF7),
    ProgramMode.stamps => const Color(0xFFFFB930),
    ProgramMode.cashback => const Color(0xFF00C896),
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      // ── ERROR STATE ─────────────────────────────
      if (controller.error.value.isNotEmpty && controller.programs.isEmpty) {
        return Center(
          child: _MessageState(
            icon: Iconsax.warning_2,
            iconColor: Colors.redAccent,
            message: controller.error.value,
            actionLabel: "retry_merchant".tr,
            onAction: () => controller.fetchPrograms(),
            size: size,
            isDark: isDark,
          ),
        );
      }

      // ── LOADING / SHIMMER STATE ──────────────────
      if (controller.loading.value && controller.programs.isEmpty) {
        return Column(
          children: List.generate(
            3,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: size.height * .014),
              child: _ShimmerProgramCard(size: size, isDark: isDark),
            ),
          ),
        );
      }

      // ── EMPTY STATE ──────────────────────────────
      if (controller.programs.isEmpty) {
        return Center(
          child: _MessageState(
            icon: Iconsax.crown,
            iconColor: const Color(0xFF7C6FF7),
            message: "no_programs_merchant".tr,
            size: size,
            isDark: isDark,
          ),
        );
      }

      // ── DATA + LOAD-MORE SCROLL ───────────────────
      return RefreshIndicator(
        onRefresh: () => controller.fetchPrograms(refresh: true),
        child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount:
              controller.programs.length +
              (controller.loadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.programs.length) {
              return Padding(
                padding: EdgeInsets.only(
                  top: size.height * .02,
                  bottom: size.height * .25,
                ),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: AppColors.primary,
                      size: 35,
                    ),
                  ),
                ),
              );
            }

            final program = controller.programs[index];
            final isLast = index == controller.programs.length - 1;

            return Padding(
              padding: EdgeInsets.only(
                top: size.height * .02,
                bottom: isLast ? size.height * .25 : 0,
              ),
              child: _ProgramCard(
                program: program,
                color: _color(program.uiMode),
                icon: _icon(program.uiMode),
                modeKey: _modeKey(program.uiMode),
                isDark: isDark,
                size: size,
                onTapCard: () {
                  showDialog(
                    context: context,
                    builder: (_) => ProgramQrDialog(
                      programLink:
                          program.joinUrl ??
                          "https://vclub.app/program/ABCD1234",
                    ),
                  );
                },
                onFreeze: () => ProgramFreezeDialog.show(context, program),
                onClients: () => AppNavigator.to(
                  ClientsProgram(id: program.id, name: program.name),
                ),
                onDetails: () =>
                    AppNavigator.to(ProgramDetailsScreen(program: program)),
              ),
            );
          },
        ),
      );
    });
  }
}

// ── PROGRAM CARD ──────────────────────────────────────────────────────────────

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.color,
    required this.icon,
    required this.modeKey,
    required this.isDark,
    required this.size,
    required this.onTapCard,
    required this.onFreeze,
    required this.onClients,
    required this.onDetails,
  });

  final ProgramModel program;
  final Color color;
  final IconData icon;
  final String modeKey;
  final bool isDark;
  final Size size;
  final VoidCallback onTapCard;
  final VoidCallback onFreeze;
  final VoidCallback onClients;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final isActive = program.isActive;
    final statusColor = isActive
        ? const Color(0xFF00C896)
        : const Color(0xFFFF6B6B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTapCard,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(.07)
                  : Colors.black.withOpacity(.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? .26 : .05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: color.withOpacity(.06),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── MAIN ROW ──────────────────────────────────
              Padding(
                padding: EdgeInsets.all(size.width * .042),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: size.width * .128,
                      height: size.width * .128,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: color.withOpacity(.10),
                        border: Border.all(color: color.withOpacity(.20)),
                      ),
                      child: Icon(icon, color: color, size: size.width * .052),
                    ),

                    SizedBox(width: size.width * .038),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            program.title,
                            fontSize: size.width * .038,
                            fontWeight: FontWeight.w800,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: size.height * .004),
                          AppText(
                            program.subtitle,
                            fontSize: size.width * .030,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white.withOpacity(.38)
                                : Colors.black.withOpacity(.40),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: size.width * .025),

                    // Tap-to-scan hint icon (card itself opens the QR dialog)
                    Container(
                      width: size.width * .086,
                      height: size.width * .086,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(.10),
                        border: Border.all(color: color.withOpacity(.18)),
                      ),
                      child: Icon(
                        Iconsax.scan_barcode,
                        color: color,
                        size: size.width * .038,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? Colors.white.withOpacity(.055)
                    : Colors.black.withOpacity(.05),
              ),

              // ── MODE CHIP + STATUS ─────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * .042,
                  vertical: size.height * .012,
                ),
                child: Row(
                  children: [
                    _Chip(icon: icon, label: modeKey.tr, color: color, size: size),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * .028,
                        vertical: size.height * .005,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(.10),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: statusColor.withOpacity(.22)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: size.width * .018,
                            height: size.width * .018,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor,
                            ),
                          ),
                          SizedBox(width: size.width * .016),
                          AppText(
                            isActive ? "program_active".tr : "program_inactive".tr,
                            fontSize: size.width * .028,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? Colors.white.withOpacity(.055)
                    : Colors.black.withOpacity(.05),
              ),

              // ── ACTION BUTTONS (in-card) ─────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * .032,
                  size.height * .012,
                  size.width * .032,
                  size.height * .014,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _PillActionButton(
                        icon: isActive ? Iconsax.lock : Iconsax.unlock,
                        label: isActive
                            ? "freeze_action".tr
                            : "unfreeze_action".tr,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.primary,
                        size: size,
                        onTap: onFreeze,
                      ),
                    ),
                    SizedBox(width: size.width * .022),
                    Expanded(
                      child: _PillActionButton(
                        icon: Iconsax.profile_2user,
                        label: "clients_action".tr,
                        color: AppColors.primary,
                        size: size,
                        onTap: onClients,
                      ),
                    ),
                    SizedBox(width: size.width * .022),
                    Expanded(
                      child: _PillActionButton(
                        icon: Iconsax.document_text_1,
                        label: "details_action".tr,
                        color: AppColors.primary,
                        size: size,
                        onTap: onDetails,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── IN-CARD PILL ACTION BUTTON ────────────────────────────────────────────────

class _PillActionButton extends StatelessWidget {
  const _PillActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Size size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: size.height * .011),
          decoration: BoxDecoration(
            color: color.withOpacity(.11),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(.22), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: size.width * .044),
              SizedBox(height: size.height * .004),
              AppText(
                label,
                fontSize: size.width * .026,
                fontWeight: FontWeight.w700,
                color: color,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── CHIP ──────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .028,
        vertical: size.height * .005,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size.width * .030, color: color),
          SizedBox(width: size.width * .014),
          AppText(
            label,
            fontSize: size.width * .028,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }
}

// ── SHIMMER PROGRAM CARD ───────────────────────────────────────────────────────

class _ShimmerProgramCard extends StatefulWidget {
  const _ShimmerProgramCard({required this.size, required this.isDark});

  final Size size;
  final bool isDark;

  @override
  State<_ShimmerProgramCard> createState() => _ShimmerProgramCardState();
}

class _ShimmerProgramCardState extends State<_ShimmerProgramCard>
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
    final baseColor = isDark
        ? Colors.white.withOpacity(.06)
        : Colors.black.withOpacity(.05);
    final highlightColor = isDark
        ? Colors.white.withOpacity(.14)
        : Colors.black.withOpacity(.10);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.07)
              : Colors.black.withOpacity(.06),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(size.width * .042),
            child: Row(
              children: [
                _shimmerBox(
                  width: size.width * .128,
                  height: size.width * .128,
                  radius: 18,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                SizedBox(width: size.width * .038),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * .028,
                          vertical: size.height * .005,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: _shimmerBox(
                          width: size.width * .14,
                          height: 12,
                          radius: 6,
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * .028,
                          vertical: size.height * .005,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: _shimmerBox(
                          width: size.width * .14,
                          height: 12,
                          radius: 6,
                          baseColor: baseColor,
                          highlightColor: highlightColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: size.width * .025),
                _shimmerBox(
                  width: size.width * .086,
                  height: size.width * .086,
                  radius: size.width * .043,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withOpacity(.055)
                : Colors.black.withOpacity(.05),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * .042,
              vertical: size.height * .012,
            ),
            child: Row(
              children: [
                _shimmerBox(
                  width: size.width * .2,
                  height: 20,
                  radius: 30,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                const Spacer(),
                _shimmerBox(
                  width: size.width * .18,
                  height: 20,
                  radius: 30,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 140),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          SizedBox(height: size.height * .016),
          AppText(
            message,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withOpacity(.65)
                : Colors.black.withOpacity(.55),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: size.height * .018),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: iconColor.withOpacity(.10),
                ),
                child: AppText(
                  actionLabel!,
                  color: iconColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}