import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/FortuneWheel/View/Widgets/FortuneWheelStats.dart';
import 'package:vclub/Features/Client/FortuneWheel/View/Widgets/FortunewheelCard.dart';

class FortuenWheel extends StatefulWidget {
  const FortuenWheel({super.key});

  @override
  State<FortuenWheel> createState() => _FortuenWheelState();
}

class _FortuenWheelState extends State<FortuenWheel> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.01),

                Align(
                  alignment: isRTL
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child:  FadeSlide(
              delayMs: 200,
              child : AppText(
                    'fortune_wheel',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  )),
                ),

                SizedBox(height: size.height * 0.01),

                Align(
                  alignment: isRTL
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: FadeSlide(
              delayMs: 250,
              child : AppText(
                    "spins_available".trParams({
                      "count": "2",
                      "time": "23h 14min",
                    }),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                )),
                SizedBox(height: size.height * 0.02),
              FadeSlide(
              delayMs: 300,
              child :  FortuneStatsGrid(
                  availableSpins: 2,
                  wins: 3,
                  participations: 7,
                  winRate: 0.55,
                )),
                SizedBox(height: size.height * 0.02),
               FadeSlide(
              delayMs: 350,
              child : FortuneWheelCard() ),
                SizedBox(height: size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
