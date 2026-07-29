import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Core/BottomSheets.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Features/Auth/Views/Login.dart';
import 'package:vclub/Features/Client/Cards/Controllers/ClientCradsController.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Main/Controllers/MainController.dart';
import 'package:vclub/Features/Client/Main/Views/Widgets/ClientNavBar.dart';
import 'package:vclub/Features/Client/Main/Views/Widgets/Drawer.dart';
import 'package:vclub/Features/Client/Main/Views/Widgets/MainAppBar.dart';
import 'package:vclub/Features/Client/Notifications/Controllers/ClientNotificationsController.dart';

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

        appBar: MainAppBar(
          themeService: Get.find<ThemeService>(),
          onLogout: () {
            showLogoutBottomSheet(
              onConfirm: () async {
                await TokenStorage.clear();
                dashcontroller.resetControllerData();
                cardscontroller.resetControllerData();
                notifcontroller.resetNotifications();
                AppNavigator.to(Login());
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
