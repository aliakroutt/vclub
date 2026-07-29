import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class FortuneWheelCard extends StatefulWidget {
  const FortuneWheelCard({super.key});

  @override
  State<FortuneWheelCard> createState() => _FortuneWheelCardState();
}

class _FortuneWheelCardState extends State<FortuneWheelCard>
    with SingleTickerProviderStateMixin {
  final StreamController<int> _controller = StreamController<int>();
  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 2),
  );
  late AnimationController _btnController;
  late Animation<double> _scaleAnim;
  final List<Color> wheelColors = [
    const Color.fromARGB(255, 140, 245, 3) ,
    const Color(0xFFFFFFFF),
    const Color.fromARGB(255, 140, 245, 3) ,
    const Color(0xFFFFFFFF),
    const Color.fromARGB(255, 140, 245, 3) ,
    const Color(0xFFFFFFFF),
  ];

  final List<_Reward> rewards = [
    _Reward("50 Points", Iconsax.star_1),
    _Reward("Gift", Iconsax.gift),
    _Reward("10% OFF", Iconsax.discount_shape),
    _Reward("Cashback", Iconsax.money_3),
    _Reward("VIP Day", Iconsax.crown),
    _Reward("Free Coffee", Iconsax.cup),
  ];

  bool isSpinning = false;

  void spin() async {
    if (isSpinning) return;

    setState(() => isSpinning = true);

    final index = Fortune.randomInt(0, rewards.length);

    _controller.add(index);

    await Future.delayed(const Duration(seconds: 4));

    _confetti.play();

    setState(() => isSpinning = false);
  }

  @override
  void initState() {
    super.initState();

    _btnController = AnimationController(
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.1,
      vsync: this,
    );

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.close();
    _confetti.dispose();
    _btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(
                          14,
                        ), // not fully round = modern feel
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.gift_copy,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            "fortune_wheel",
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: size.height * 0.01),
                          AppText(
                            "VClub Rewards",
                            fontSize: size.width * 0.03,
                            color: Theme.of(
                              context,
                            ).textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppText(
                        "3 spins",
                        fontSize: size.width * 0.03,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.05),

                /// WHEEL
                Center(
                  child: Container(
                    height: size.width * 0.7,
                    width: size.width * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(150),
                      border: Border.all(width: 10, color: AppColors.primary),
                    ),
                    child: FortuneWheel(
                      alignment: Alignment.center,
                      selected: _controller.stream,
                      animateFirst: false,
                      physics: CircularPanPhysics(
                        duration: const Duration(seconds: 1),
                        curve: Curves.decelerate,
                      ),
                      items: [
                        for (int i = 0; i < rewards.length; i++)
                          FortuneItem(
                            style: FortuneItemStyle(
                              color: wheelColors[i % wheelColors.length],
                              borderColor: Colors.white.withOpacity(0.15),
                              borderWidth: 1,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  rewards[i].icon,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    rewards[i].title,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                /// BUTTON
                Center(
                  child: GestureDetector(
                    onTapDown: (_) => _btnController.forward(),
                    onTapUp: (_) {
                      _btnController.reverse();
                      spin();
                    },
                    onTapCancel: () => _btnController.reverse(),
                    child: AnimatedBuilder(
                      animation: _scaleAnim,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnim.value,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.07,
                              vertical: size.height * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: isSpinning
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Iconsax.gift,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      AppText(
                                        "Spin the wheel",
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),

                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _rewardChip("50 pts", Iconsax.star),
                      _rewardChip("Gift", Iconsax.gift),
                      _rewardChip("10% Off", Iconsax.discount_shape),
                      _rewardChip("Cashback", Iconsax.money_3),
                      _rewardChip("VIP", Iconsax.crown),
                      _rewardChip("Coffee", Iconsax.cup),
                    ],
                  ),
                ),
              ],
            ),

            /// CONFETTI
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.pink,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Reward {
  final String title;
  final IconData icon;

  _Reward(this.title, this.icon);
}

Widget _rewardChip(String label, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: AppColors.primary.withOpacity(0.15)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
