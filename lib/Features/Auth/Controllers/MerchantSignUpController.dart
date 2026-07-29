import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vclub/API/MerchantApiClient.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Widgets/AppLoader.dart';
import 'package:vclub/Features/Auth/Controllers/PaymentWebView.dart';
import 'package:vclub/Features/Auth/Views/Login.dart';

class MerchantSignUpController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordObscure = true.obs;
  final isConfirmPasswordObscure = true.obs;

  void togglePassword() => isPasswordObscure.value = !isPasswordObscure.value;

  void toggleConfirmPassword() =>
      isConfirmPasswordObscure.value = !isConfirmPasswordObscure.value;

  RxInt selectedPlanIndex = (-1).obs;

  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  bool get hasSelectedPlan => selectedPlanIndex.value != -1;

  // =========================
  // COMPANY DATA
  // =========================
  final companyNameController = TextEditingController();
  final tradeNameController = TextEditingController(); // optional
  final siretController = TextEditingController(); // required
  final industryController = TextEditingController();
  final phoneController =
      TextEditingController(); // renamed from PhoneController
  final StreetController = TextEditingController();
  final houseNumberController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();

  // Country dial code selected in the phone field (e.g. "+33")
  final RxString phoneCountryCode = "+33".obs;
  final RxString phoneCountryIso = "FR".obs;
  final isphone_valid = false.obs;
  // Online Presence
  final googleReviewLinkController = TextEditingController();

  // Social Media
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final linkedinController = TextEditingController();
  final xController = TextEditingController();
  final youtubeController = TextEditingController();
  final tiktokController = TextEditingController();

  // =========================
  // LOGO (optional)
  // =========================
  final Rxn<File> logoFile = Rxn<File>();
  final RxBool isPickingLogo = false.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickLogoFromGallery() async {
    try {
      isPickingLogo.value = true;

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        logoFile.value = File(pickedFile.path);
        logoFile.refresh();
      }
    } catch (e) {
      debugPrint("Logo pick error: $e");
    } finally {
      isPickingLogo.value = false;
    }
  }

  final List<String> planKeys = ["STARTER", "BUSINESS", "PREMIUM", "QUOTE"];
  void removeLogo() {
    logoFile.value = null;
  }

  // =========================
  // VALIDATORS
  // =========================

  bool validateMerchantDetails() {
    List<String> errors = [];

    if (firstNameController.text.trim().isEmpty) {
      errors.add("first_name_required".tr);
    }

    if (lastNameController.text.trim().isEmpty) {
      errors.add("last_name_required".tr);
    }

    if (emailController.text.trim().isEmpty) {
      errors.add("email_required".tr);
    } else if (!GetUtils.isEmail(emailController.text.trim())) {
      errors.add("invalid_email".tr);
    }

    if (passwordController.text.trim().isEmpty) {
      errors.add("password_required".tr);
    } else if (passwordController.text.trim().length < 8) {
      errors.add("password_too_short".tr);
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      errors.add("confirm_password_required".tr);
    } else if (confirmPasswordController.text.trim() !=
        passwordController.text.trim()) {
      errors.add("passwords_do_not_match".tr);
    }

    if (errors.isNotEmpty) {
      AppSnackBar.multipleErrors(errors);
      return false;
    }

    return true;
  }

  bool validateCompanyData() {
    List<String> errors = [];

    // Trade name is optional -> no check

    if (companyNameController.text.trim().isEmpty) {
      errors.add("company_name_required".tr);
    }

    if (siretController.text.trim().isEmpty) {
      errors.add("siret_required".tr);
    } else if (siretController.text.trim().replaceAll(' ', '').length != 14) {
      errors.add("invalid_siret".tr);
    }

    if (industryController.text.trim().isEmpty) {
      errors.add("industry_required".tr);
    }

    if (phoneController.text.trim().isEmpty) {
      errors.add("phone_required".tr);
    } else if (isphone_valid.value == false) {
      errors.add("invalid_phone".tr);
    }

    if (StreetController.text.trim().isEmpty) {
      errors.add("street_required".tr);
    }

    if (houseNumberController.text.trim().isEmpty) {
      errors.add("house_number_required".tr);
    }

    if (postalCodeController.text.trim().isEmpty) {
      errors.add("postal_code_required".tr);
    }

    if (cityController.text.trim().isEmpty) {
      errors.add("city_required".tr);
    }

    if (countryController.text.trim().isEmpty) {
      errors.add("country_required".tr);
    }

    // Logo, social media, google review link: all optional -> no checks

    if (errors.isNotEmpty) {
      AppSnackBar.multipleErrors(errors);
      return false;
    }

    return true;
  }

  // =========================
  // CLEANUP
  // =========================
  Future<void> merchantSignUp_api() async {
    if (!validateMerchantDetails() || !validateCompanyData()) return;

    try {
      AppLoader.show();

      // 1) Upload logo first, only if the user picked one
      String logoUrl = "";
      // if (logoFile.value != null) {
      //   final uploadResponse = await MerchantApiClient.uploadLogo(
      //     file: logoFile.value!,
      //   );
      //   final uploadData = uploadResponse.data;

      //   if (uploadData is Map<String, dynamic> && uploadData["url"] != null) {
      //     logoUrl = uploadData["url"].toString();
      //   } else {
      //     AppLoader.hide();
      //     AppSnackBar.error("Failed to upload logo");
      //     return;
      //   }
      // }

      // 2) Build payload
      final payload = {
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "companyName": companyNameController.text.trim(),
        "tradeName": tradeNameController.text.trim(),
        "siret": siretController.text.trim(),
        "industry": industryController.text.trim(),
        "contactPhone": phoneController.text.trim(),
        "address": {
          "street": StreetController.text.trim(),
          "houseNumber": houseNumberController.text.trim(),
          "postalCode": postalCodeController.text.trim(),
          "city": cityController.text.trim(),
          "country": countryController.text.trim(),
        },
        "logo": logoUrl,
        "facebook": facebookController.text.trim(),
        "instagram": instagramController.text.trim(),
        "linkedin": linkedinController.text.trim(),
        "twitter": xController.text.trim(),
        "youtube": youtubeController.text.trim(),
        "tiktok": tiktokController.text.trim(),
        "googleReviewLink": googleReviewLinkController.text.trim(),
        "plan": planKeys[selectedPlanIndex.value],
        "language": Get.locale?.languageCode ?? "fr",
      };

      // 3) Call signup
      final response = await MerchantApiClient.signUp(payload: payload);
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        AppLoader.hide();
        AppSnackBar.error("Unexpected server response");
        return;
      }
      debugPrint(data.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ MERCHANT SIGNUP SUCCESS");

        final checkoutUrl = data["checkoutUrl"] as String?;

        

        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          Get.to(Login());
          reset();
          AppLoader.hide();
          AppNavigator.to(CheckoutWebViewScreen(checkoutUrl: checkoutUrl));
          return;
        }
      } else {
        AppLoader.hide();
        final message = data["message"]?.toString() ?? "Sign up failed";
        AppSnackBar.error(message);
      }
    } on DioException catch (e) {
      AppLoader.hide();
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>)
          ? data["message"]?.toString()
          : null;
      AppSnackBar.error(message ?? "Network error, please try again");
    } catch (e, st) {
      AppLoader.hide();
      debugPrint("❌ MERCHANT SIGNUP ERROR: $e");
      debugPrint("$st");
      AppSnackBar.error("Unexpected error occurred");
    }
  }

  // New fields
  final quoteMessageController = TextEditingController();
  final RxBool isSubmittingQuote = false.obs;

  bool validateQuoteMessage() {
    List<String> errors = [];

    if (quoteMessageController.text.trim().isEmpty) {
      errors.add("message_required".tr);
    } else if (quoteMessageController.text.trim().length < 10) {
      errors.add("message_too_short".tr);
    }

    if (errors.isNotEmpty) {
      AppSnackBar.multipleErrors(errors);
      return false;
    }
    return true;
  }

  Future<void> submitQuoteRequest() async {
    if (!validateQuoteMessage()) return;

    isSubmittingQuote.value = true;

    quoteMessageController.clear();

    await Future.delayed(const Duration(seconds: 2));

    isSubmittingQuote.value = false;
    Get.to(Login());
    AppSnackBar.success("quote_request_success_title".tr);
  }
  // try {
  //   isSubmittingQuote.value = true;

  //   final payload = {
  //     "message": quoteMessageController.text.trim(),
  //     "language": Get.locale?.languageCode ?? "fr",
  //   };

  //   final response = await MerchantApiClient.quoteRequest(payload: payload);
  //   final data = response.data;

  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     isSubmittingQuote.value = false;
  //     AppSnackBar.success("quote_request_sent".tr);
  //     Get.back();
  //   } else {
  //     isSubmittingQuote.value = false;
  //     final message = (data is Map<String, dynamic>)
  //         ? data["message"]?.toString()
  //         : null;
  //     AppSnackBar.error(message ?? "quote_request_failed".tr);
  //   }
  // } on DioException catch (e) {
  //   isSubmittingQuote.value = false;
  //   final data = e.response?.data;
  //   final message =
  //       (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
  //   AppSnackBar.error(message ?? "Network error, please try again");
  // } catch (e, st) {
  //   isSubmittingQuote.value = false;
  //   debugPrint("❌ QUOTE REQUEST ERROR: $e");
  //   debugPrint("$st");
  //   AppSnackBar.error("Unexpected error occurred");
  // } finally {
  //   quoteMessageController.dispose;
  // }

  void reset() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    quoteMessageController.clear();
    companyNameController.clear();
    tradeNameController.clear();
    siretController.clear();
    industryController.clear();
    phoneController.clear();
    StreetController.clear();
    houseNumberController.clear();
    postalCodeController.clear();
    cityController.clear();
    countryController.clear();

    googleReviewLinkController.clear();

    facebookController.clear();
    instagramController.clear();
    linkedinController.clear();
    xController.clear();
    youtubeController.clear();
    tiktokController.clear();
    phoneCountryCode.value = "" ;
    phoneCountryIso.value = "" ;
    isphone_valid.value = false;

    
  }
}
