import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Core/Widgets/app_text_field.dart';
import 'package:vclub/Core/responsive.dart';
import 'package:vclub/Features/Auth/Controllers/MerchantSignUpController.dart';
import 'package:vclub/Features/Auth/Views/Login.dart';
import 'package:vclub/Features/Auth/Widgets/AuthSignInText.dart';
import 'package:vclub/Features/Auth/Widgets/BackButtonWidget.dart';
import 'package:vclub/Features/Auth/Widgets/LanguageSelector.dart';
import 'package:vclub/Features/Auth/Widgets/LogoUploader.dart';
import 'package:vclub/Features/Auth/Widgets/Merchant/CustomPlanMessageSupport.dart';
import 'package:vclub/Features/Auth/Widgets/Merchant/SectionCard.dart';
import 'package:vclub/Features/Auth/Widgets/NextButton.dart';

class CompanyData extends StatefulWidget {
  const CompanyData({super.key});

  @override
  State<CompanyData> createState() => _CompanyDataState();
}

class _CompanyDataState extends State<CompanyData> {
  final controller = Get.put(MerchantSignUpController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isArabic = Get.locale?.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return KeyboardDismissOnTap(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),
                Row(children: [Spacer(), LanguageSelector()]),
                SizedBox(height: size.height * 0.04),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlide(
                      delayMs: 200,
                      child: PremiumSectionCard(
                        title: "company_information".tr,
                        subtitle: "company_information_desc".tr,
                        icon: Iconsax.building,
                        child: Column(
                          children: [
                            AppTextField(
                              label: "company_name".tr,
                              hint: "enter_company_name".tr,
                              controller: controller.companyNameController,
                              prefixIcon: Iconsax.building,
                            ),

                            const SizedBox(height: 16),

                            /// TRADE NAME (optional)
                            AppTextField(
                              label: "trade_name_optional".tr,
                              hint: "enter_trade_name".tr,
                              controller: controller.tradeNameController,
                              prefixIcon: Iconsax.tag,
                            ),

                            const SizedBox(height: 16),

                            /// SIRET (required)
                            AppTextField(
                              label: "siret".tr,
                              hint: "enter_siret".tr,
                              controller: controller.siretController,
                              keyboardType: TextInputType.number,
                              prefixIcon: Iconsax.hashtag,
                            ),

                            const SizedBox(height: 16),

                            AppTextField(
                              label: "industry".tr,
                              hint: "enter_industry".tr,
                              controller: controller.industryController,
                              prefixIcon: Iconsax.briefcase,
                            ),

                            const SizedBox(height: 16),

                            /// PHONE WITH COUNTRY CODE
                            IntlPhoneField(
                              dropdownIcon: Icon(
                                Iconsax.arrow_down_1_copy,
                                size: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: "enter_phone".tr,
                                labelStyle: TextStyle(
                                  fontSize: Responsive.scaleW(context, 15),
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF2D3142),
                                  fontWeight: FontWeight.w400,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: Responsive.scaleW(context, 13),
                                  color: isDark
                                      ? Colors.white38
                                      : const Color(0xFFADB5BD),
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : const Color(0xFFF4F5F7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              initialCountryCode: 'FR',
                              searchText: "search_country".tr,
                              disableLengthCheck: true,
                              onChanged: (phone) {
                                try {
                                  controller.isphone_valid.value = phone
                                      .isValidNumber();
                                } catch (e) {
                                  controller.isphone_valid.value = false;
                                }
                                print(controller.isphone_valid.value);
                                controller.phoneController.text =
                                    phone.completeNumber;
                                controller.phoneCountryCode.value =
                                    phone.countryCode;
                                controller.phoneCountryIso.value =
                                    phone.countryISOCode;
                              },
                            ),
                            const SizedBox(height: 16),

                            AppTextField(
                              label: "street".tr,
                              hint: "enter_street".tr,
                              controller: controller.StreetController,
                              prefixIcon: Iconsax.location,
                            ),

                            const SizedBox(height: 16),
                            AppTextField(
                              label: "house_number".tr,
                              hint: "enter_house_number".tr,
                              controller: controller.houseNumberController,
                              prefixIcon: Iconsax.home_2,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: "postal_code".tr,
                              hint: "enter_postal_code".tr,
                              controller: controller.postalCodeController,
                              prefixIcon: Iconsax.code,
                            ),

                            const SizedBox(height: 16),
                            AppTextField(
                              label: "city".tr,
                              hint: "enter_city".tr,
                              controller: controller.cityController,
                              prefixIcon: Iconsax.building_3,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: "country".tr,
                              hint: "enter_country".tr,
                              controller: controller.countryController,
                              prefixIcon: Iconsax.global,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    FadeSlide(
                      delayMs: 350,
                      child: PremiumSectionCard(
                        title: "online_presence".tr,
                        subtitle: "online_presence_desc".tr,
                        icon: Iconsax.global,
                        child: Column(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 180,
                                child: LogoUploader(
                                  logoFile: controller.logoFile,
                                  onPick: controller.pickLogoFromGallery,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            AppTextField(
                              label: "google_review_link".tr,
                              hint: "google_review_link".tr,
                              controller: controller.googleReviewLinkController,
                              prefixIcon: Iconsax.google_1,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.01),
                    FadeSlide(
                      delayMs: 500,
                      child: PremiumSectionCard(
                        title: "social_media".tr,
                        subtitle: "social_media_desc".tr,
                        icon: Iconsax.share,
                        child: Column(
                          children: [
                            AppTextField(
                              label: "facebook_url".tr,
                              hint: "facebook_url".tr,
                              controller: controller.facebookController,
                              prefixIcon: Iconsax.facebook,
                            ),

                            const SizedBox(height: 16),

                            AppTextField(
                              label: "instagram_url".tr,
                              hint: "instagram_url".tr,
                              controller: controller.instagramController,
                              prefixIcon: Iconsax.instagram,
                            ),

                            const SizedBox(height: 16),

                            AppTextField(
                              label: "linkedin_url".tr,
                              hint: "linkedin_url".tr,
                              controller: controller.linkedinController,
                              prefixIcon: Iconsax.link,
                            ),

                            const SizedBox(height: 16),

                            AppTextField(
                              label: "x_url".tr,
                              hint: "x_url".tr,
                              controller: controller.xController,
                              prefixIcon: Iconsax.messages,
                            ),

                            const SizedBox(height: 16),

                            AppTextField(
                              label: "youtube_url".tr,
                              hint: "youtube_url".tr,
                              controller: controller.youtubeController,
                              prefixIcon: Iconsax.youtube,
                            ),

                            const SizedBox(height: 16),

                            AppTextField(
                              label: "tiktok_url".tr,
                              hint: "tiktok_url".tr,
                              controller: controller.tiktokController,
                              prefixIcon: Icons.tiktok,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    FadeSlide(
                      delayMs: 600,
                      child: NextButton(
                        text: "sign_up".tr,
                        isEnabled: true,
                        width: size.width,
                        onTap: () {
                          if (controller.planKeys[controller.selectedPlanIndex.value] == "QUOTE" ){
                            AppNavigator.to(const CustomPlanRequestScreen());
                          }else {
                            controller.merchantSignUp_api();
                          }
                        }
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    FadeSlide(
                      delayMs: 700,
                      child: BackButtonWidget(
                        text: "back",
                        width: size.width,
                        onTap: () {
                          Get.back();
                        },
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),
                    FadeSlide(
                      delayMs: 750,
                      child: AuthSignInText(
                        onTap: () => AppNavigator.to(Login()),
                      ),
                    ),
                    SizedBox(height: size.height * 0.06),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
