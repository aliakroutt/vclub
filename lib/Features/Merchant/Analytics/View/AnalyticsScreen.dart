import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Analytics/View/Widgets/AnalyticsStats.dart';
import 'package:vclub/Features/Merchant/Analytics/View/Widgets/SummaryCard.dart';
import 'package:vclub/Features/Merchant/Analytics/View/Widgets/TopClientsCard.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';


class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late final MerchantDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MerchantDashboardController());
    controller.fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return KeyboardDismissOnTap(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RefreshIndicator(
              onRefresh: () => controller.fetchDashboardData(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
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
                          "statistics",
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
                          'analytics_dashboard',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    const AnalyticsStatsColumn(),
                    SizedBox(height: size.height * 0.02),
                    FadeSlide(delayMs: 400, child: const TopClientsCard()),
                    SizedBox(height: size.height * 0.02),
                    FadeSlide(delayMs: 450, child: const AnalyticsSummaryCard()),

                    SizedBox(height: size.height * 0.15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}