import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Rewards/Controllers/RewardsClientController.dart';
import 'package:vclub/Features/Client/Rewards/View/Widgets/FortuneRewardsList.dart';
import 'package:vclub/Features/Client/Rewards/View/Widgets/ProgramsRewardList.dart';
import 'package:vclub/Features/Client/Rewards/View/Widgets/ReviewsCard.dart';
import 'package:vclub/Features/Client/Rewards/View/Widgets/RewardStatsCard.dart';
import 'package:vclub/Features/Client/Rewards/View/Widgets/RewardsTabBar.dart';

class MyRewards extends StatefulWidget {
  const MyRewards({super.key});

  @override
  State<MyRewards> createState() => _MyRewardsState();
}

class _MyRewardsState extends State<MyRewards> {
  final dashcontroller = ClientDashboardController.to;
  final GoogleReviewController controller = Get.find<GoogleReviewController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashcontroller.fetchRewards();
      dashcontroller.fetchWheelHistory();
      controller.fetchGoogleReview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  child: FadeSlide(
                    delayMs: 200,
                    child: AppText(
                      'my_rewards',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.01),
                Align(
                  alignment: isRTL
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: FadeSlide(
                    delayMs: 250,
                    child: AppText(
                      "my_rewards_subtitle",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Obx(
                  () => FadeSlide(
                    delayMs: 300,
                    child: RewardsStatsRow(
                      isDark: isDark,
                      programsPoints: dashcontroller.rewards.length,
                      fortunePoints: dashcontroller.wheel_history.length,
                      onProgramsTap: () {},
                      onFortuneTap: () {},
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                FadeSlide(delayMs: 350, child: RewardsTabBar(isDark: isDark)),
                SizedBox(height: size.height * 0.01),
               FadeSlide(delayMs: 400, child: Obx(() {
                  switch (controller.selectedIndex.value) {
                    case 0:
                      return ProgramsRewardsList(height:size.height * 0.52 ,);
                    case 1:
                      return FortuneRewardsList(height:size.height * 0.52 ,);
                    default:
                      return GoogleReviewRewardCard(review: controller.googleReview.value!,);
                  }
                })),

                // SizedBox(height: size.height * 0.02),
               

               

               

                // SizedBox(height: size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
