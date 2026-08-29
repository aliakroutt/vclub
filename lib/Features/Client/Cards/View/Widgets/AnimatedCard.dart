import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vclub/API/Socket/Models/ScanRewardValidatedEvent.dart';
import 'package:vclub/API/SocketService.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Cards/Controllers/ClientCradsController.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';
import 'package:vclub/Features/Client/Dashboard/Models/Client_Reward_Model.dart';

class _ModeMeta {
  final IconData icon;
  final Color color;
  const _ModeMeta(this.icon, this.color);
}

_ModeMeta _metaForMode(String mode) {
  switch (mode) {
    case 'stamps':
      return const _ModeMeta(Iconsax.award, Color(0xFF29B6F6));
    case 'cashback':
      return const _ModeMeta(Iconsax.money_recive, Color(0xFF4CAF50));
    case 'points':
    default:
      return const _ModeMeta(Iconsax.star_1, Color(0xFFFFB300));
  }
}

double _safeProgress(num value, num target) {
  if (target <= 0) return 0.0;
  return (value / target).clamp(0.0, 1.0).toDouble();
}

class LoyaltyCardViewAnimated extends StatefulWidget {
  final ClientCardModel card;
  final VoidCallback? onClaimReward;
  const LoyaltyCardViewAnimated({super.key, required this.card, this.onClaimReward});

  @override
  State<LoyaltyCardViewAnimated> createState() =>
      _LoyaltyCardViewAnimatedState();
}

class _LoyaltyCardViewAnimatedState extends State<LoyaltyCardViewAnimated>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _ambientCtrl;
  late final AnimationController _progressCtrl;

  late final Animation<double> _entryScale;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entryScale = CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.easeOutBack,
    );
    _entryFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _ambientCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeOutCubic,
    );

    _entryCtrl.forward();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _progressCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _ambientCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  double get _targetProgress {
    final p = widget.card.program;
    switch (p.mode) {
      case 'stamps':
        return _safeProgress(widget.card.stamps, p.stampsPerReward);
      case 'points':
        return _safeProgress(widget.card.points, p.pointsPerReward);
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final meta = _metaForMode(card.program.mode);
    final accent = meta.color;
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;

    return _buildCardShell(accent, isDark, size, meta, card);
  }

  Widget _buildCardShell(
    Color accent,
    bool isDark,
    Size size,
    _ModeMeta meta,
    ClientCardModel card,
  ) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(accent, Colors.black, isDark ? 0.55 : 0.15)!,
              Color.lerp(accent, Colors.black, isDark ? 0.75 : 0.35)!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.45),
              blurRadius: 30,
              spreadRadius: -8,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildAmbientBlobs(accent),
            ), // ← wrap in Positioned.fill
            Padding(
              padding: EdgeInsets.all(size.width * 0.055),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ← add this
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(card, meta),
                  SizedBox(height: size.height * 0.03),
                  _buildBody(card, accent, size),
                  SizedBox(height: size.height * 0.02),
                  _buildFooter(card, accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientBlobs(Color accent) {
    return AnimatedBuilder(
      animation: _ambientCtrl,
      builder: (context, _) {
        final t = _ambientCtrl.value * 2 * math.pi;
        return Stack(
          children: [
            Positioned(
              top: -50 + math.sin(t) * 12,
              right: -40 + math.cos(t) * 10,
              child: _blob(Colors.white.withOpacity(0.08), 160),
            ),
            Positioned(
              bottom: -60 + math.cos(t) * 14,
              left: -40 + math.sin(t) * 10,
              child: _blob(accent.withOpacity(0.35), 180),
            ),
          ],
        );
      },
    );
  }

  Widget _blob(Color color, double d) => Container(
    width: d,
    height: d,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _buildHeader(ClientCardModel card, _ModeMeta meta) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: card.company.logo.isEmpty
              ? Icon(meta.icon, color: Colors.white, size: 24)
              : ClipOval(
                  child: Image.network(
                    card.company.logo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(meta.icon, color: Colors.white, size: 24),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                card.company.name,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              AppText(
                card.program.name,
                fontSize: 12,
                color: Colors.white.withOpacity(0.75),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(50),
          ),
          child: AppText(
            card.tier.toUpperCase(),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  bool _isRewardReady(ClientCardModel card) {
  switch (card.program.mode) {
    case 'points':
      return card.program.pointsPerReward > 0 &&
          card.points >= card.program.pointsPerReward;
    case 'stamps':
      return card.program.stampsPerReward > 0 &&
          card.stamps >= card.program.stampsPerReward;
    case 'cashback':
      // No numeric reward-threshold field for cashback on ProgramModel
      // (cashbackMinPurchase is the earn-rate minimum, not a payout target).
      return card.cardCompleted;
    default:
      return card.cardCompleted;
  }
}

 Widget _buildBody(ClientCardModel card, Color accent, Size size) {
  if (_isRewardReady(card)) {
    return _buildClaimRewardButton(card, accent, size);
  }
  switch (card.program.mode) {
    case 'stamps':
      return _buildStamps(card, accent, size);
    case 'cashback':
      return _buildCashback(card, accent, size);
    case 'points':
    default:
      return _buildPoints(card, accent, size);
  }
}

Widget _buildClaimRewardButton(ClientCardModel card, Color accent, Size size) {
  return AnimatedBuilder(
    animation: _ambientCtrl,
    builder: (context, _) {
      final pulse = (math.sin(_ambientCtrl.value * 2 * math.pi) + 1) / 2; // 0..1
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.gift, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              AppText(
                'reward_ready_client'.tr,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 4),
          AppText(
            'reward_ready_subtitle_client'.tr,
            fontSize: 12,
            color: Colors.white.withOpacity(0.75),
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: size.height * 0.02),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: (){
                showLoyaltyRewardQrDialog(context, card: card, accent: accent);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.25 + pulse * 0.25),
                      blurRadius: 20 + pulse * 10,
                      spreadRadius: pulse * 2,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.magic_star, size: 18, color: accent),
                    const SizedBox(width: 8),
                    AppText(
                      'claim_reward_client'.tr,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

 Widget _buildPoints(ClientCardModel card, Color accent, Size size) {
  final target = card.program.pointsPerReward;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: card.points.toDouble()),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            AppText(
              '${value.round()}',
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            if (target > 0)
              AppText(
                'pts_target_client'.trParams({'target': '$target'}),
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _animatedProgressBar(),
    ],
  );
}

 Widget _buildStamps(ClientCardModel card, Color accent, Size size) {
  final target = card.program.stampsPerReward;
  final earned = card.stamps;
  final useDots = target > 0 && target <= 12;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: earned.toDouble()),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            AppText(
              '${value.round()}',
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            if (target > 0)
              AppText(
                'stamps_target_client'.trParams({'target': '$target'}),
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      if (useDots)
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(target, (i) {
            final filled = i < earned;
            final start = (i / target) * 0.6;
            final end = start + 0.4;
            return AnimatedBuilder(
              animation: _progressCtrl,
              builder: (context, _) {
                final t = Curves.easeOutBack.transform(
                  ((_progressCtrl.value - start) / (end - start)).clamp(
                    0.0,
                    1.0,
                  ),
                );
                return Transform.scale(
                  scale: filled ? t : 1,
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? Colors.white
                          : Colors.white.withOpacity(0.15),
                      border: filled
                          ? null
                          : Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: filled
                        ? Icon(Iconsax.award, size: 13, color: accent)
                        : null,
                  ),
                );
              },
            );
          }),
        )
      else
        _animatedProgressBar(),
    ],
  );
}

  Widget _buildCashback(ClientCardModel card, Color accent, Size size) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(
        'balance_label_client'.tr,
        fontSize: 12,
        color: Colors.white.withOpacity(0.7),
        fontWeight: FontWeight.w700,
      ),
      const SizedBox(height: 4),
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: card.cashbackBalance.toDouble()),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => AppText(
          "${value.toStringAsFixed(2)}€",
          fontSize: 42,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Icon(
            Iconsax.percentage_circle,
            size: 15,
            color: Colors.white.withOpacity(0.85),
          ),
          const SizedBox(width: 4),
          AppText(
            'cashback_earn_info_client'.trParams({
              'percent': '${card.program.cashbackPercent}',
            }),
            fontSize: 12,
            color: Colors.white.withOpacity(0.75),
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    ],
  );
}

  Widget _animatedProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, _) {
        final value = _progressAnim.value * _targetProgress;
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 10,
            width: double.infinity,
            color: Colors.white.withOpacity(0.18),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white.withOpacity(0.8)],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(ClientCardModel card, Color accent) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(
            Iconsax.repeat,
            size: 14,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(width: 5),
          AppText(
            'visits_count_client'.trParams({'count': '${card.visits}'}),
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
      if (card.cardCompleted)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: AppText(
            'reward_ready_client'.tr,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ),
    ],
  );
}
}

void showLoyaltyRewardQrDialog(
  BuildContext context, {
  required ClientCardModel card,
  required Color accent,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Transform.scale(
        scale: 0.9 + (0.1 * curved.value),
        child: Opacity(
          opacity: anim.value,
          child: _LoyaltyRewardQrDialog(card: card, accent: accent),
        ),
      );
    },
  );
}

class _LoyaltyRewardQrDialog extends StatefulWidget {
  final ClientCardModel card;
  final Color accent;

  const _LoyaltyRewardQrDialog({required this.card, required this.accent});

  @override
  State<_LoyaltyRewardQrDialog> createState() => _LoyaltyRewardQrDialogState();
}

class _LoyaltyRewardQrDialogState extends State<_LoyaltyRewardQrDialog> {
  final _dashboard = ClientDashboardController.to;
   final controller = ClientCardsController.to;
  bool _loading = true;
  RewardModel? _reward;

  StreamSubscription<Map<String, dynamic>>? _socketSub;
  bool _validated = false;
  ScanRewardValidatedEvent? _validatedEvent;

  @override
  void initState() {
    super.initState();
    _loadReward();
    _socketSub = SocketService.to.onRewardValidated.listen(_onRewardValidated);
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }

  void _onRewardValidated(Map<String, dynamic> data) {
    if (!mounted) return;

    final event = ScanRewardValidatedEvent.fromJson(data);

    // Match on company + code — code is the specific reward coupon shown
    // in this exact dialog, so this avoids reacting to a different reward
    // validated elsewhere for the same company.
    if (event.companyId != widget.card.company.id) return;
    if (_reward != null && event.code != _reward!.code) return;

    setState(() {
      _validated = true;
      _validatedEvent = event;
    });

    // Refresh dashboard data (rewards list, cards, stats) in the background.
    // CardDetails (if this dialog was opened from there) listens to the
    // same socket event independently and updates its own local card copy.
    _dashboard.fetchDashboardData();
    controller.fetchCards();
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _loadReward() async {
    setState(() => _loading = true);

    // Refresh the rewards list from the API
    await _dashboard.fetchRewards();

    // Find the reward tied to this card: same membership, same company,
    // and not yet validated.
    final match = _dashboard.rewards.cast<RewardModel>().firstWhereOrNull(
          (r) =>
              r.membershipId == widget.card.id &&
              r.company.id == widget.card.company.id &&
              r.validatedBy == null,
        );

    if (!mounted) return;
    setState(() {
      _reward = match;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final accent = widget.accent;

    final dialogWidth = size.width < 480 ? size.width * 0.86 : 380.0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- Header ----------
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, Color.lerp(accent, Colors.black, 0.18)!],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.width * 0.022),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                      ),
                      child: Icon(
                        Iconsax.medal_star_copy,
                        color: Colors.white,
                        size: size.width * 0.055,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: AppText(
                        'loyalty_reward_title_client'.tr,
                        fontSize: size.width * 0.042,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.014),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.16),
                        ),
                        child: Icon(
                          Iconsax.close_circle,
                          color: Colors.white,
                          size: size.width * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- Body ----------
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.03,
                ),
                child: _validated
                    ? _RewardValidatedSuccessState(
                        size: size,
                        accent: accent,
                        event: _validatedEvent!,
                        onClose: () => Navigator.of(context).pop(),
                      )
                    : (_loading
                        ? _LoadingState(size: size, accent: accent)
                        : _reward == null
                            ? _NoRewardState(size: size, isDark: isDark)
                            : _RewardQrContent(
                                reward: _reward!,
                                size: size,
                                dialogWidth: dialogWidth,
                                accent: accent,
                                isDark: isDark,
                              )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _RewardValidatedSuccessState extends StatefulWidget {
  final Size size;
  final Color accent;
  final ScanRewardValidatedEvent event;
  final VoidCallback onClose;

  const _RewardValidatedSuccessState({
    required this.size,
    required this.accent,
    required this.event,
    required this.onClose,
  });

  @override
  State<_RewardValidatedSuccessState> createState() =>
      _RewardValidatedSuccessStateState();
}

class _RewardValidatedSuccessStateState
    extends State<_RewardValidatedSuccessState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _badgeScale;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _badgeScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
    ]).animate(_ctrl);

    _ringScale = Tween(begin: 0.6, end: 1.8).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    _ringOpacity = Tween(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );

    _fadeIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    _slideUp = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(_fadeIn);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final accent = widget.accent;
    final event = widget.event;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Animated badge with expanding ring pulse ──
        SizedBox(
          width: size.width * 0.32,
          height: size.width * 0.32,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: _ringOpacity.value,
                    child: Transform.scale(
                      scale: _ringScale.value,
                      child: Container(
                        width: size.width * 0.22,
                        height: size.width * 0.22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 2),
                        ),
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: _badgeScale.value,
                    child: Container(
                      width: size.width * 0.22,
                      height: size.width * 0.22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [accent, Color.lerp(accent, Colors.black, 0.2)!],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.45),
                            blurRadius: 24,
                            spreadRadius: -2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.medal_star_copy,
                        color: Colors.white,
                        size: size.width * 0.11,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        SizedBox(height: size.height * 0.02),

        FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  'reward_validated_title_client'.tr,
                  fontSize: size.width * 0.048,
                  fontWeight: FontWeight.w800,
                ),
                SizedBox(height: size.height * 0.016),

                // ── Reward name pill ──
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.014,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [accent.withOpacity(0.14), accent.withOpacity(0.05)],
                    ),
                    border: Border.all(color: accent.withOpacity(0.3), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.gift, color: accent, size: size.width * 0.05),
                      SizedBox(width: size.width * 0.02),
                      Flexible(
                        child: AppText(
                          event.rewardName,
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.014),
                AppText(
                  'reward_validated_subtitle_client'.tr,
                  fontSize: size.width * 0.034,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  textAlign: TextAlign.center,
                ),

                // ── Done button ──
                SizedBox(height: size.height * 0.026),
                _DoneButtonReward(accent: accent, onTap: widget.onClose, size: size),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DoneButtonReward extends StatelessWidget {
  final Color accent;
  final VoidCallback onTap;
  final Size size;

  const _DoneButtonReward({
    required this.accent,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [accent, Color.lerp(accent, Colors.black, 0.18)!],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.tick_square, size: size.width * 0.042, color: Colors.white),
              SizedBox(width: size.width * 0.02),
              AppText(
                'scan_done_client'.tr,
                fontSize: size.width * 0.038,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final Size size;
  final Color accent;

  const _LoadingState({required this.size, required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.22,
      child: Center(
        child: CircularProgressIndicator(color: accent, strokeWidth: 2.5),
      ),
    );
  }
}

class _NoRewardState extends StatelessWidget {
  final Size size;
  final bool isDark;

  const _NoRewardState({required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Iconsax.gift,
          size: size.width * 0.12,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
        SizedBox(height: size.height * 0.015),
        AppText(
          'no_reward_available_client'.tr,
          fontSize: size.width * 0.035,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RewardQrContent extends StatelessWidget {
  final RewardModel reward;
  final Size size;
  final double dialogWidth;
  final Color accent;
  final bool isDark;

  const _RewardQrContent({
    required this.reward,
    required this.size,
    required this.dialogWidth,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(size.width * 0.035),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.25), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.15),
                blurRadius: 18,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: QrImageView(
            data: reward.code,
            version: QrVersions.auto,
            size: dialogWidth * 0.56,
            backgroundColor: Colors.white,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color.lerp(accent, Colors.black, 0.35)!,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.018),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: size.height * 0.008,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.08),
          ),
          child: AppText(
            reward.code,
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        AppText(
          'claim_reward_instructions_client'.tr,
          fontSize: size.width * 0.033,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

