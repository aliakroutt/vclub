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
        return _MessageState(
          icon: Iconsax.warning_2,
          iconColor: Colors.redAccent,
          message: controller.error.value,
          actionLabel: "retry_merchant".tr,
          onAction: () => controller.fetchPrograms(),
          size: size,
          isDark: isDark,
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
              child: _SwipeableProgramCard(
                program: program,
                color: _color(program.uiMode),
                icon: _icon(program.uiMode),
                modeKey: _modeKey(program.uiMode),
                isDark: isDark,
                size: size,
              ),
            );
          },
        ),
      );
    });
  }
}

// ── SWIPEABLE WRAPPER ─────────────────────────────────────────────────────────

class _SwipeableProgramCard extends StatefulWidget {
  const _SwipeableProgramCard({
    required this.program,
    required this.color,
    required this.icon,
    required this.modeKey,
    required this.isDark,
    required this.size,
  });

  final ProgramModel program;
  final Color color;
  final IconData icon;
  final String modeKey;
  final bool isDark;
  final Size size;

  @override
  State<_SwipeableProgramCard> createState() => _SwipeableProgramCardState();
}

class _SwipeableProgramCardState extends State<_SwipeableProgramCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _reveal;

  bool get _isAr => Get.locale?.languageCode == 'ar';

  double get _actionsW => widget.size.width * .48;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _reveal = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _open() => _ctrl.forward();
  void _close() => _ctrl.reverse();

  void _onDragEnd(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (_isAr) {
      if (v > 200) _open();
      if (v < -200) _close();
    } else {
      if (v < -200) _open();
      if (v > 200) _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _reveal,
        builder: (_, __) {
          final slide = _actionsW * _reveal.value;
          return ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // ── ACTION BUTTONS (behind) ──────────────
                Positioned.fill(
                  child: Align(
                    alignment: _isAr
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: SizedBox(
                      width: _actionsW,
                      child: _ActionButtons(
                        isActive: widget.program.active,
                        color: widget.color,
                        size: widget.size,
                        isDark: widget.isDark,
                        isAr: _isAr,
                        onFreeze: () {
                          _close();
                         ProgramFreezeDialog.show(context, widget.program);
                        },
                        onQr: () {
                          _close();
                          showDialog(
                            context: context,
                            builder: (_) => ProgramQrDialog(
                              programLink:
                                  widget.program.joinUrl ??
                                  "https://vclub.app/program/ABCD1234",
                            ),
                          );
                        },
                        onClients: () {
                          _close();
                          AppNavigator.to(ClientsProgram(id: widget.program.id, name: widget.program.name));
                        },
                      ),
                    ),
                  ),
                ),

                // ── CARD (slides) ────────────────────────
                // ── CARD (slides) ────────────────────────
                Transform.translate(
                  offset: Offset(_isAr ? slide : -slide, 0),
                  child: GestureDetector(
                    onTap: () {
                      if (_reveal.value > 0) {
                        _close();
                      } else {
                        AppNavigator.to(
                          ProgramDetailsScreen(program: widget.program),
                        );
                      }
                    },
                    child: _ProgramCard(
                      program: widget.program,
                      color: widget.color,
                      icon: widget.icon,
                      modeKey: widget.modeKey,
                      isDark: widget.isDark,
                      size: widget.size,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── ACTION BUTTONS ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.color,
    required this.size,
    required this.isDark,
    required this.isAr,
    required this.isActive,
    required this.onFreeze,
    required this.onQr,
    required this.onClients,
  });

  final Color color;
  final Size size;
  final bool isDark;
  final bool isAr;
  final bool isActive;   
  final VoidCallback onFreeze;
  final VoidCallback onQr;
  final VoidCallback onClients;

  List<Widget> _buildRow(List<Widget> buttons, double gap) {
    final ordered = isAr ? buttons.reversed.toList() : buttons;
    final result = <Widget>[];
    for (int i = 0; i < ordered.length; i++) {
      if (i > 0) result.add(SizedBox(width: gap));
      result.add(ordered[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final btnSize = size.width * .118;
    final gap = size.width * .022;

    final buttons = [
      _ActionBtn(
        icon: isActive ? Iconsax.lock : Iconsax.unlock,
        color: isActive ? const Color(0xFFFF9F43) : const Color(0xFF00C896),
        size: btnSize,
        isDark: isDark,
        onTap: onFreeze,
      ),
      _ActionBtn(
        icon: Iconsax.scan_barcode,
        color: color,
        size: btnSize,
        isDark: isDark,
        onTap: onQr,
      ),
      _ActionBtn(
        icon: Iconsax.profile_2user,
        color: const Color(0xFF00C896),
        size: btnSize,
        isDark: isDark,
        onTap: onClients,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: gap,
        vertical: size.height * .018,
      ),
      child: Row(
        mainAxisAlignment: isAr
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: _buildRow(buttons, gap),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.size,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final double size;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(.11),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(.24), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * .42),
      ),
    );
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
  });

  final ProgramModel program;
  final Color color;
  final IconData icon;
  final String modeKey;
  final bool isDark;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final isActive = program.isActive;
    final statusColor = isActive
        ? const Color(0xFF00C896)
        : const Color(0xFFFF6B6B);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
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

                Container(
                  width: size.width * .086,
                  height: size.width * .086,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(.10),
                    border: Border.all(color: color.withOpacity(.18)),
                  ),
                  child: Icon(
                    isRtl
                        ? Iconsax.arrow_circle_left
                        : Iconsax.arrow_circle_right,
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

          // ── FOOTER: mode chip + status ─────────────────
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
        ],
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
                      // footer shimmer — replace the two fixed-height boxes with:
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
                      // footer shimmer — replace the two fixed-height boxes with:
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
      padding: EdgeInsets.symmetric(vertical: size.height * .06),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
