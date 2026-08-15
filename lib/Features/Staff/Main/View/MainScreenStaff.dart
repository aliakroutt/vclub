import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Core/BottomSheets.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Storage/Controllers/AgentController.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Core/Storage/UserStorage.dart';
import 'package:vclub/Features/Auth/Views/Login.dart';
import 'package:vclub/Features/Merchant/QRScanner/QrSCanner.dart';
import 'package:vclub/Features/Staff/Main/Controllers/StaffMainController.dart';
import 'package:vclub/Features/Staff/Main/View/Widgets/AppBarStaff.dart';
import 'package:vclub/Features/Staff/Main/View/Widgets/StaffNavBar.dart';

class MainScreenStaff extends StatefulWidget {
  const MainScreenStaff({super.key});

  @override
  State<MainScreenStaff> createState() => _MainScreenStaffState();
}

class _MainScreenStaffState extends State<MainScreenStaff> {
  final controller = Get.put(StaffMainController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable system back button
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        appBar: MainAppBarStaff(
          themeService: Get.find<ThemeService>(),
          onHomeTap: () {
            controller.selectIndex(0);
          },
          onLogout: () {
            showLogoutBottomSheet(
              onConfirm: () async {
                await TokenStorage.clear();
                UserStorage.clear();
                AgentController.to.clear();
                AppNavigator.to(Login());
                controller.selectIndex(0);
              },
            );
          },
        ),

        body: Stack(
          children: [
            Obx(() {
              return controller.pages[controller.selectedIndex.value];
            }),

            Obx(
              () => Positioned(
                bottom: 5,
                left: 0,
                right: 0,
                child: StaffNavBar(
                  selectedIndex: controller.selectedIndex.value,
                  onItemTapped: (int value) {
                    controller.selectIndex(value);
                  },
                  onAddTap: () {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) Get.to(QrScannerMerchant(isRedeem: false));
                    });
                  },
                  onRedeemTap: () {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) Get.to(QrScannerMerchant(isRedeem: true));
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
