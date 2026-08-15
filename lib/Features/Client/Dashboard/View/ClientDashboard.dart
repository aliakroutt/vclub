import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/ClubsClient/View/Clubs.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/TabController.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/CardsSection.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/ClientActionsRow.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/ClientStats.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/HistoryTab.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/RewardsTab.dart';
import 'package:vclub/Features/Client/Main/Controllers/MainController.dart';
import 'package:vclub/Features/Client/Notifications/Controllers/ClientNotificationsController.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final tabController = Get.put(ClientTabController());
  final controller = Get.put(MainController());
   final dashcontroller = ClientDashboardController.to;
   final profilecontroller = Get.find<ClientController>();
   final NotificationsController notifcontroller =
      Get.find<NotificationsController>();
 @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    dashcontroller.fetchDashboardData();
    notifcontroller.fetchNotifications();
  });
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child:  SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.01),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:  Align(
                      alignment: isRTL
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: FadeSlide(
              delayMs: 200,
              child : AppText(
                        'dashboard_title_client'.trParams({'name': profilecontroller.client.value!.firstName}),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      )),
                    ),
                  
                ),

                SizedBox(height: size.height * 0.01),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:  Align(
                      alignment: isRTL
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: FadeSlide(
              delayMs: 250,
              child : AppText(
                        'dashboard_subtitle_client'.tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      )),
                    
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeSlide(
              delayMs: 300,
              child :  ClientStatsRow(),
                )),
                SizedBox(height: size.height * 0.02),

                Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeSlide(
              delayMs: 400,
              child :  ClientActionsColumn(
                      onFortuneWheelTap: () {
                      controller.selectIndex(5);
                      },
                      onGoogleReviewTap: () {
                      AppNavigator.to(ClubScreen(clubSlug: 'techazum', role: ClubViewerRole.staff));
                      },
                    )),
                  
                ),
                SizedBox(height: size.height * 0.02),
                Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeSlide(
              delayMs: 450,
              child : MyCardsSection())),
                SizedBox(height: size.height * 0.02),
               Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const FadeSlide(
              delayMs: 500,
              child : RewardsTab())),
                SizedBox(height: size.height * 0.02),
               Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const FadeSlide(
              delayMs: 550,
              child : HistoryTab())),
                SizedBox(height: size.height * 0.02),
                SizedBox(height: size.height * 0.15),
              ],
            ),
          
        ),
      ),
    );
  }
}



// Widget _buildTab(int index) {
//   switch (index) {
//     case 0:
//       return const RewardsTab();
//     case 1:
//       return const HistoryTab();
//     default:
//       return const HistoryTab();
//   }
// }
