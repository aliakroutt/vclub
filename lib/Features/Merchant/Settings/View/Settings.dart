import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Settings/Controllers/SessionsController.dart';
import 'package:vclub/Features/Merchant/Settings/Controllers/SettingsController.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/AdresseCard.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/GeneraleInfoCard.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/OnlinePresenceCard.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/SessionsCard.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/SocialMediaCard.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/UpdatePasswordCard.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }
    if (!Get.isRegistered<SessionsController>()) {
      Get.put(SessionsController());
    }
    final session_controller = Get.find<SessionsController>();
    session_controller.fetchSessions() ;
    final controller = Get.find<SettingsController>();
    controller.seedFromMerchant();
    controller.newPasswordController.addListener(() {
      controller.newPasswordValue.value = controller.newPasswordController.text;
    });
  }

  @override
  void dispose() {
    final controller = Get.find<SettingsController>();
    controller.resetAll();
    super.dispose();
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
                        "settings".tr,
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
                        'settings_description'.tr,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),
                  const FadeSlide(
                    delayMs: 300,
                    child: GeneralInformationCard(),
                  ),
                  SizedBox(height: size.height * 0.02),
                  const FadeSlide(delayMs: 350, child: AddressCard()),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(delayMs: 400, child: OnlinePresenceCard()),
                  SizedBox(height: size.height * 0.02),
                  // const FadeSlide(delayMs: 430, child: BrandingRegionalCard()),
                  // SizedBox(height: size.height * 0.02),
                  const FadeSlide(delayMs: 460, child: SocialMediaCard()),
                  SizedBox(height: size.height * 0.02),
                  ChangePasswordCard(),
                  SizedBox(height: size.height * 0.02),
                  SessionsCard(),
                  SizedBox(height: size.height * 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
