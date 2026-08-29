import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Core/BottomSheets.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Features/Auth/Services/LogoutService.dart';
import 'package:vclub/Features/Merchant/Audit/Controllers/MerchantAuditController.dart';
import 'package:vclub/Features/Merchant/Avtivity/Controllers/MerchantActivityController.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/InvoicesController.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/PlansController.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/SmsAddonController.dart';
import 'package:vclub/Features/Merchant/Clients/Controllers/MerchantClientsController.dart';
import 'package:vclub/Features/Merchant/Compains/Controllers/CampaignController.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';
import 'package:vclub/Features/Merchant/Employee/Controllers/EmployeeController.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelHistoryController.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelHomeController.dart';
import 'package:vclub/Features/Merchant/GoogleReview/Controllers/MerchantGoogleReviewController.dart';
import 'package:vclub/Features/Merchant/Main/Controllers/MerchantMainController.dart';
import 'package:vclub/Features/Merchant/Main/View/Widgets/AppBarMerchant.dart';
import 'package:vclub/Features/Merchant/Main/View/Widgets/DrawerMerchant.dart';
import 'package:vclub/Features/Merchant/Main/View/Widgets/MerchantNavBar.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/MerchantProgramsController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/MerchantNotificationsController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/MerchantNotificationsListController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsMerchant.dart';
import 'package:vclub/Features/Merchant/QRScanner/QrSCanner.dart';
import 'package:vclub/Features/Merchant/QRcode/View/MerchantQrCodeScreen.dart';
import 'package:vclub/Features/Merchant/QRcode/View/SlideUpRoute.dart';
import 'package:vclub/Features/Merchant/Redemptions/Controllers/MerchantRedemptionsController.dart';
import 'package:vclub/Features/Merchant/Rewards/Controllers/RewardsMerchantController.dart';
import 'package:vclub/Features/Merchant/Settings/Controllers/SessionsController.dart';

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
          onQrTap: () {
            Navigator.of(
              context,
            ).push(SlideUpRoute(page: const MerchantQrCodeScreen()));
          },
          onNotificationTap: () {
            AppNavigator.to(NotificationsInboxMerchant());
          },
          themeService: Get.find<ThemeService>(),
         onLogout: () {
  showLogoutBottomSheet(
    onConfirm: () async {
      await LogoutService.logout(
        resetControllers: [
          safeReset<MerchantController>(() => MerchantController.to.clear()),
          safeReset<MerchantDashboardController>(() => MerchantDashboardController.to.resetControllerData()),
          safeReset<MerchantProgramsController>(() => MerchantProgramsController.to.resetControllerData()),
          safeReset<MerchantAuditController>(() => MerchantAuditController.to.resetControllerData()),
          safeReset<MerchantActivityController>(() => MerchantActivityController.to.resetControllerData()),
          safeReset<InvoicesController>(() => InvoicesController.to.resetControllerData()),
          safeReset<PlansController>(() => PlansController.to.resetControllerData()),
          safeReset<SmsAddonController>(() => SmsAddonController.to.resetControllerData()),
          safeReset<ClientsController>(() => ClientsController.to.resetControllerData()),
          safeReset<CampaignController>(() => CampaignController.to.resetControllerData()),
          safeReset<EmployeeController>(() => EmployeeController.to.resetControllerData()),
          safeReset<FortuneWheelHistoryController>(() => FortuneWheelHistoryController.to.resetControllerData()),
          safeReset<FortuneWheelHomeController>(() => FortuneWheelHomeController.to.resetControllerData()),
          safeReset<MerchantGoogleReviewController>(() => MerchantGoogleReviewController.to.resetControllerData()),
          safeReset<MerchantNotificationsController>(() => MerchantNotificationsController.to.resetControllerData()),
          safeReset<MerchantNotificationsListController>(() => MerchantNotificationsListController.to.resetNotifications()),
          safeReset<MerchantRedemptionsController>(() => MerchantRedemptionsController.to.resetControllerData()),
          safeReset<RewardsMerchantController>(() => RewardsMerchantController.to.resetControllerData()),
          safeReset<SessionsController>(() => SessionsController.to.resetControllerData()),
        ],
      );
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
        ),

        body: Stack(
          children: [
            Obx(() {
              return controller.pages[controller.selectedIndex.value];
            }),

            Obx(() {
              // Hide the floating navbar entirely for merchants without an
              // active plan — mirrors the drawer's restricted menu behavior.
              if (MerchantController.to.isFreePlan) {
                return const SizedBox.shrink();
              }

              return Positioned(
                bottom: 5,
                child: GlassNavBar(
                  selectedIndex: controller.selectedIndex.value,
                  onItemTapped: (int value) {
                    if (value == 0) {
                      controller.selectIndex(value);
                    } else if (value == 1) {
                      controller.selectIndex(value);
                    } else if (value == 2) {
                      controller.selectIndex(2);
                    } else if (value == 3) {
                      controller.selectIndex(10);
                    }
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
              );
            }),
          ],
        ),
      ),
    );
  }
}
