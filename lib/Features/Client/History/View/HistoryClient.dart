import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/HistoryTab.dart';
import 'package:vclub/Features/Client/History/View/Widgets/HistoryStats.dart';

class HistoryClient extends StatefulWidget {
  const HistoryClient({super.key});

  @override
  State<HistoryClient> createState() => _HistoryClientState();
}

class _HistoryClientState extends State<HistoryClient> {
  final dashcontroller = ClientDashboardController.to;

  @override
  void initState() {
    dashcontroller.fetchHistory();
    dashcontroller.fetchStats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';
    Widget _buildShimmerList() {
      final size = MediaQuery.of(context).size;

      return Column(
        children: List.generate(
          6,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.012),
            child: _buildShimmerItem(size),
          ),
        ),
      );
    }

    Widget _buildHistoryEmpty() {
      final size = MediaQuery.of(context).size;

      return FadeSlide(
        delayMs: 200,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.06,
            horizontal: size.width * 0.1,
          ),
          child: Column(
            children: [
              Container(
                width: size.width * 0.2,
                height: size.width * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
                child: Icon(
                  Iconsax.clock,
                  size: size.width * 0.09,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              AppText(
                "history_empty_title".tr,
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: size.height * 0.006),
              AppText(
                "history_empty_subtitle".tr,
                fontSize: size.width * 0.032,
                color: Colors.grey,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildHistoryError() {
      final size = MediaQuery.of(context).size;

      return FadeSlide(
        delayMs: 200,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.06),
          child: Column(
            children: [
              Icon(
                Iconsax.warning_2,
                size: size.width * 0.09,
                color: Colors.redAccent,
              ),
              SizedBox(height: size.height * 0.016),
              AppText(
                dashcontroller.historyError.value,
                fontSize: size.width * 0.032,
                color: Colors.grey,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.016),
              TextButton(
                onPressed: () => dashcontroller
                    .fetchHistory(), // adjust to your actual method name
                child: AppText(
                  "retry".tr,
                  fontSize: size.width * 0.032,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                      'points_history',
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
                      "track_all_transactions",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                FadeSlide(
                  delayMs: 300,
                  child: PointsStatsRow(
                    earned: dashcontroller.stats.value!.pointsEarned,
                    spent: dashcontroller.stats.value!.pointsSpent,
                    bonuses: dashcontroller.stats.value!.bonusReceived,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                FadeSlide(
                  delayMs: 350,
                  child: Row(
                    children: [
                      // LEFT / RIGHT TITLE depending on language
                      Expanded(
                        child: Align(
                          alignment: isRTL
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: AppText(
                            "all_transactions".tr,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // COUNT (fixed style pill)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AppText(
                          "entries_count".trParams({
                            "count": dashcontroller.history.length.toString(),
                          }),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Obx(() {
                  if (dashcontroller.historyLoading.value) {
                    return _buildShimmerList();
                  }

                  if (dashcontroller.historyError.value.isNotEmpty) {
                    return _buildHistoryError();
                  }

                  if (dashcontroller.history.isEmpty) {
                    return _buildHistoryEmpty();
                  }

                  return FadeSlide(
                    delayMs: 400,
                    child: ListView.separated(
                      shrinkWrap: true,
                      primary: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashcontroller.history.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: size.height * 0.012),
                      itemBuilder: (context, index) {
                        final t = dashcontroller.history[index];
                        return TransactionCard(transaction: t);
                      },
                    ),
                  );
                }),
                SizedBox(height: size.height * 0.15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildShimmerItem(Size size) {
  return Shimmer.fromColors(
    baseColor: Color(0xFFE8EAF0),
    highlightColor: Color(0xFFF7F8FC),
    child: Container(
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            width: size.width * 0.12,
            height: size.width * 0.12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: size.width * 0.35,
                  height: size.height * 0.014,
                  color: Colors.white,
                ),
                SizedBox(height: size.height * 0.008),
                Container(
                  width: size.width * 0.5,
                  height: size.height * 0.012,
                  color: Colors.white,
                ),
                SizedBox(height: size.height * 0.008),
                Container(
                  width: size.width * 0.25,
                  height: size.height * 0.01,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Container(
            width: size.width * 0.16,
            height: size.height * 0.03,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
