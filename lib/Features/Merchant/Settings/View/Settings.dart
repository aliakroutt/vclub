import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Settings/Controllers/SettingsController.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/AdresseCard.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/GeneraleInfoCard.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/OnlinePresenceCard.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/SocialMediaCard.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/UpdatePasswordCard.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final companyController = TextEditingController(text: "VClub Technologies");
  final industryController = TextEditingController(text: "Restaurant");
  final phoneController = TextEditingController(text: "+216 99 999 999");
  final streetController = TextEditingController(
    text: "Avenue Habib Bourguiba",
  );
  final houseNumberController = TextEditingController(text: "25");
  final postalCodeController = TextEditingController(text: "1001");
  final cityController = TextEditingController(text: "Tunis");
  final countryController = TextEditingController(text: "Tunisia");
  final facebookController = TextEditingController(
    text: "https://facebook.com/your-page",
  );

  final instagramController = TextEditingController(
    text: "https://instagram.com/your-page",
  );

  final linkedinController = TextEditingController(
    text: "https://linkedin.com/company/your-page",
  );

  final twitterController = TextEditingController(
    text: "https://x.com/your-page",
  );

  final youtubeController = TextEditingController(
    text: "https://youtube.com/@your-channel",
  );

  final tiktokController = TextEditingController(
    text: "https://tiktok.com/@your-account",
  );
  final controller = Get.put(SettingsController());

  @override
  void dispose() {
    companyController.dispose();
    industryController.dispose();
    phoneController.dispose();
    streetController.dispose();
    houseNumberController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
    countryController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    linkedinController.dispose();
    twitterController.dispose();
    youtubeController.dispose();
    tiktokController.dispose();
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
                        "settings",
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
                        'settings_description',
                        fontSize: 14,
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
                    child: GeneralInformationCard(
                      companyController: companyController,
                      industryController: industryController,
                      phoneController: phoneController,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(
                    delayMs: 350,
                    child: AddressCard(
                      streetController: streetController,
                      houseNumberController: houseNumberController,
                      postalCodeController: postalCodeController,
                      cityController: cityController,
                      countryController: countryController,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(delayMs: 400, child: OnlinePresenceCard()),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(
                    delayMs: 450,
                    child: SocialMediaCard(
                      facebookController: facebookController,
                      instagramController: instagramController,
                      linkedinController: linkedinController,
                      twitterController: twitterController,
                      youtubeController: youtubeController,
                      tiktokController: tiktokController,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  

                  FadeSlide(
                    delayMs: 500,
                    child: SizedBox(
                      width: double.infinity,
                      height: size.height * 0.062,
                      child: ElevatedButton(
                        onPressed: () {},
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: AppColors.primary.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ).copyWith(
                              elevation: WidgetStateProperty.resolveWith(
                                (states) => states.contains(WidgetState.pressed)
                                    ? 0
                                    : 4,
                              ),
                              shadowColor: WidgetStateProperty.all(
                                AppColors.primary.withOpacity(0.35),
                              ),
                            ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.tick_circle,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: size.width * 0.025),
                            AppText(
                              "save".tr,
                              fontSize: size.width * 0.038,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  ChangePasswordCard(),
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
