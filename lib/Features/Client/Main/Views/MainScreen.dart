import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Core/BottomSheets.dart';
import 'package:vclub/Features/Auth/Services/LogoutService.dart';
import 'package:vclub/Features/Client/Cards/Controllers/ClientCradsController.dart';
import 'package:vclub/Features/Client/ClubsClient/Controller/ClientClubsController.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/FortuneWheel/Controllers/FortuneWheelController.dart';
import 'package:vclub/Features/Client/Main/Controllers/MainController.dart';
import 'package:vclub/Features/Client/Main/Views/Widgets/ClientNavBar.dart';
import 'package:vclub/Features/Client/Main/Views/Widgets/Drawer.dart';
import 'package:vclub/Features/Client/Main/Views/Widgets/MainAppBar.dart';
import 'package:vclub/Features/Client/Notifications/Controllers/ClientNotificationsController.dart';
import 'package:vclub/Features/Client/Rewards/Controllers/RewardsClientController.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final controller = Get.put(MainController());
  final dashcontroller = ClientDashboardController.to;
  final cardscontroller = ClientCardsController.to;
  final NotificationsController notifcontroller =
      Get.find<NotificationsController>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable system back button
      child: Scaffold(
        extendBody: true,
         resizeToAvoidBottomInset: false,
        appBar: MainAppBar(
          themeService: Get.find<ThemeService>(),
          onLogout: () {
  showLogoutBottomSheet(
    onConfirm: () async {
      await LogoutService.logout(
        resetControllers: [
          safeReset<ClientDashboardController>(() => dashcontroller.resetControllerData()),
          safeReset<ClientCardsController>(() => cardscontroller.resetControllerData()),
          safeReset<NotificationsController>(() => notifcontroller.resetNotifications()),
          safeReset<CardsController>(() => CardsController.to.resetControllerData()),
          safeReset<FortuneWheelController>(() => FortuneWheelController.to.resetControllerData()),
          safeReset<GoogleReviewController>(() => GoogleReviewController.to.resetControllerData()),
        ],
      );
      controller.selectIndex(0);
    },
  );
}, onNotificationTap: () { 
             controller.selectIndex(6);
           },
        ),

        drawer: SafeArea(
          child: MainDrawer(
            controller: controller,
            themeService: Get.find<ThemeService>(),
          ),
        ), // we will build next

        body: Stack(
          children: [
            Obx(() {
              return controller.pages[controller.selectedIndex.value];
            }),
            Positioned(
              bottom: 5,
              child:  VClubBottomNavBar(controller: controller),
            ),
          ],
        ),
        // bottomNavigationBar: VClubBottomNavBar(controller: controller),
      ),
    );
  }
}
