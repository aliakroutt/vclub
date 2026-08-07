import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Core/BottomSheets.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Core/Storage/UserStorage.dart';
import 'package:vclub/Features/Auth/Views/Login.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';
import 'package:vclub/Features/Merchant/Main/Controllers/MerchantMainController.dart';
import 'package:vclub/Features/Merchant/Main/View/Widgets/AppBarMerchant.dart';
import 'package:vclub/Features/Merchant/Main/View/Widgets/DrawerMerchant.dart';
import 'package:vclub/Features/Merchant/Main/View/Widgets/MerchantNavBar.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/MerchantProgramsController.dart';
import 'package:vclub/Features/Merchant/QRScanner/QrSCanner.dart';

class MainScreenMerchant extends StatefulWidget {
  const MainScreenMerchant({super.key});

  @override
  State<MainScreenMerchant> createState() => _MainScreenMerchantState();
}

class _MainScreenMerchantState extends State<MainScreenMerchant> {
  final controller = Get.put(MerchantMainController());
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable system back button
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        appBar: MainAppBarMerchant(
          themeService: Get.find<ThemeService>(),
          onLogout: () {
            showLogoutBottomSheet(
              onConfirm: () async {
                await TokenStorage.clear();
                UserStorage.clear();
                MerchantController.to.clear();
                MerchantDashboardController.to.resetControllerData();
                MerchantProgramsController.to.resetControllerData();
                AppNavigator.to(Login());
                controller.selectIndex(0);
              },
            );
          },
        ),

        drawer: SafeArea(
          child: MerchantMainDrawer(
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
              child: Obx(
                () => GlassNavBar(
                  // controller: controller,
                  selectedIndex: controller.selectedIndex.value,
                  onItemTapped: (int value) {
                    if (value == 0) {
                      controller.selectIndex(value);
                    } else if (value == 1) {
                      controller.selectIndex(value);
                    } else if (value == 2) {
                      controller.selectIndex(4);
                    } else if (value == 3) {
                      controller.selectIndex(10);
                    }
                  },
                  onAddTap: () {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) Get.to(QrScannerMerchant(isRedeem: false,));
                    });
                  },

                  onRedeemTap: () {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) Get.to(QrScannerMerchant(isRedeem: true,));
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
