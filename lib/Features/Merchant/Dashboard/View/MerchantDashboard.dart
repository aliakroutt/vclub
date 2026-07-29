import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';

import 'package:vclub/Features/Merchant/Dashboard/View/Widgets/Actions.dart';
import 'package:vclub/Features/Merchant/Dashboard/View/Widgets/MerchantStats.dart';
import 'package:vclub/Features/Merchant/Dashboard/View/Widgets/RecentClientsCard.dart';
import 'package:vclub/Features/Merchant/Dashboard/View/Widgets/RewardsCard.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  final merchant = MerchantController.to.merchant.value;
  final controller = MerchantDashboardController.to;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboardData();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Scaffold(
      extendBody: true,
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
                      "welcome_back_merchant".trParams({
                        "name": merchant!.firstName,
                      }),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
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
                      'Overview'.tr,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),
                MerchantStatsGrid(),
                SizedBox(height: size.height * 0.02),
                FadeSlide(delayMs: 400, child: DashboardActions()),
                SizedBox(height: size.height * 0.02),
                RecentClientsCard(onViewAll: () {}),
                SizedBox(height: size.height * 0.02),
                RewardsCardStats(onViewAll: () {}),
                SizedBox(height: size.height * 0.15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
