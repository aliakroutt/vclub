import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Features/Auth/Services/MerchantService.dart';
import 'package:vclub/Features/Merchant/Settings/Services/SettingsApiClient.dart';
import 'package:vclub/Features/Merchant/Settings/Utils/ImageBase64.dart';
import 'package:vclub/Features/Merchant/Settings/Utils/PasswordStrength.dart';

class SettingsController extends GetxController {
  // ── GENERAL INFO ──
  final companyController = TextEditingController();
  final tradeNameController = TextEditingController();
  final siretController = TextEditingController();
  final industryController = TextEditingController();
  final phoneController = TextEditingController();
  final RxBool savingGeneralInfo = false.obs;

  // ── ADDRESS ──
  final streetController = TextEditingController();
  final houseNumberController = TextEditingController();
  final postalCodeController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final RxBool savingAddress = false.obs;

  // ── ONLINE PRESENCE ──
  final googleReviewController = TextEditingController();
  final Rx<File?> logoFile = Rx<File?>(null);
  final RxString existingLogoBase64 = "".obs;
  final RxBool savingOnlinePresence = false.obs;

  // ── BRANDING & REGIONAL (kept for future use — card is commented out) ──
  final brandColorController = TextEditingController();
  final secondaryColorController = TextEditingController();
  final countryCodeController = TextEditingController();
  final timezoneController = TextEditingController();
  final RxString currencyCode = "".obs;
  final RxString language = "".obs;
  final RxBool savingBranding = false.obs;

  // ── SOCIAL MEDIA ──
  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final linkedinController = TextEditingController();
  final twitterController = TextEditingController();
  final youtubeController = TextEditingController();
  final tiktokController = TextEditingController();
  final RxBool savingSocial = false.obs;

  // ── PASSWORD ──
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool showCurrent = false.obs;
  final RxBool showNew = false.obs;
  final RxBool showConfirm = false.obs;
  final RxBool savingPassword = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    seedFromMerchant();
  }

  void seedFromMerchant() {
    final company = MerchantController.to.merchant.value?.company;
    if (company == null) return;

    companyController.text = company.name;
    tradeNameController.text = company.tradeName ?? "";
    siretController.text = company.siret ?? "";
    industryController.text = company.industry ?? "";
    phoneController.text = company.contactPhone ?? "";

    streetController.text = company.address?.street ?? "";
    houseNumberController.text = company.address?.houseNumber ?? "";
    postalCodeController.text = company.address?.postalCode ?? "";
    cityController.text = company.address?.city ?? "";
    countryController.text = company.address?.country ?? "";

    googleReviewController.text = company.googleReviewLink ?? "";
    existingLogoBase64.value = company.logo ?? "";

    countryCodeController.text = company.countryCode ?? "";
    timezoneController.text = company.timezone ?? "";
    currencyCode.value = company.currencyCode ?? "";
    language.value = MerchantController.to.merchant.value?.language ?? "";

    facebookController.text = company.facebook ?? "";
    instagramController.text = company.instagram ?? "";
    linkedinController.text = company.linkedin ?? "";
    twitterController.text = company.twitter ?? "";
    youtubeController.text = company.youtube ?? "";
    tiktokController.text = company.tiktok ?? "";
  }

  /// The current app/merchant language, injected into every update payload
  /// so the backend always knows which language the request is in, without
  /// exposing a selector in the UI.
  String get _currentLanguage =>
      MerchantController.to.merchant.value?.language ?? Get.locale?.languageCode ?? "en";

  // ── LOGO PICKER ──
  Future<void> pickLogo() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null) {
      logoFile.value = File(image.path);
    }
  }

  void removeLogo() {
    logoFile.value = null;
  }

  // ── SECTION SAVE: GENERAL INFO ──
  Future<void> saveGeneralInfo() async {
    try {
      savingGeneralInfo.value = true;

      await SettingsApiClient.updateCompany({
        "name": companyController.text.trim(),
        "tradeName": tradeNameController.text.trim(),
        "siret": siretController.text.trim(),
        "industry": industryController.text.trim(),
        "contactPhone": phoneController.text.trim(),
        "language": _currentLanguage,
      });

      await _refreshProfile();
      AppSnackBar.success("section_updated".tr);
    } catch (e) {
      AppSnackBar.error("section_update_failed".tr);
    } finally {
      savingGeneralInfo.value = false;
    }
  }

  // ── SECTION SAVE: ADDRESS ──
  Future<void> saveAddress() async {
    try {
      savingAddress.value = true;

      await SettingsApiClient.updateCompany({
        "address": {
          "street": streetController.text.trim(),
          "houseNumber": houseNumberController.text.trim(),
          "postalCode": postalCodeController.text.trim(),
          "city": cityController.text.trim(),
          "country": countryController.text.trim(),
        },
        "language": _currentLanguage,
      });

      await _refreshProfile();
      AppSnackBar.success("section_updated".tr);
    } catch (e) {
      AppSnackBar.error("section_update_failed".tr);
    } finally {
      savingAddress.value = false;
    }
  }
  final RxString newPasswordValue = "".obs;

Future<void> updatePassword() async {
  final current = currentPasswordController.text;
  final newPass = newPasswordController.text;
  final confirm = confirmPasswordController.text;

  if (current.isEmpty) {
    AppSnackBar.error("current_password_required".tr);
    return;
  }

  final validationError = PasswordStrength.validate(newPass);
  if (validationError != null) {
    AppSnackBar.error(validationError.tr);
    return;
  }

  if (newPass != confirm) {
    AppSnackBar.error("passwords_do_not_match".tr);
    return;
  }

  if (current == newPass) {
    AppSnackBar.error("new_password_same_as_current".tr);
    return;
  }

  try {
    savingPassword.value = true;

    final result = await SettingsApiClient.changePassword(
      currentPassword: current,
      newPassword: newPass,
    );

    if (result.success) {
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      newPasswordValue.value = "";
      AppSnackBar.success("password_updated".tr); // translated, not API message
    } else {
      AppSnackBar.error(result.errorMessage ?? "change_password_failed_generic".tr);
    }
  } finally {
    savingPassword.value = false;
  }
}

  // ── SECTION SAVE: ONLINE PRESENCE (logo + review link) ──
 Future<void> saveOnlinePresence() async {
  try {
    savingOnlinePresence.value = true;

    final payload = <String, dynamic>{
      "googleReviewLink": googleReviewController.text.trim(),
      "language": _currentLanguage,
    };

    final file = logoFile.value;
    if (file != null) {
      final encoded = await ImageBase64.fromFile(file);
      debugPrint("ℹ️ Logo base64 length: ${encoded.length} chars (~${(encoded.length / 1024).toStringAsFixed(1)} KB)");
      payload["logo"] = encoded;
    }

    await SettingsApiClient.updateCompany(payload);

    await _refreshProfile();
    logoFile.value = null;
    AppSnackBar.success("section_updated".tr);
  } catch (e) {
    debugPrint("❌ saveOnlinePresence error: $e");

    String message = "section_update_failed".tr;
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data["message"] != null) {
        final m = data["message"];
        message = m is List ? m.join(", ") : m.toString();
      } else if (e.response?.statusCode == 413) {
        message = "logo_too_large".tr;
      }
    }
    AppSnackBar.error(message);
  } finally {
    savingOnlinePresence.value = false;
  }
}

  // ── SECTION SAVE: BRANDING & REGIONAL (kept, card currently unused) ──
  void setCurrencyCode(String value) => currencyCode.value = value;
  void setLanguage(String value) => language.value = value;

  Future<void> saveBranding() async {
    try {
      savingBranding.value = true;

      await SettingsApiClient.updateCompany({
        "brandColor": brandColorController.text.trim(),
        "secondaryColor": secondaryColorController.text.trim(),
        "countryCode": countryCodeController.text.trim(),
        "currencyCode": currencyCode.value,
        "timezone": timezoneController.text.trim(),
        "language": _currentLanguage,
      });

      await _refreshProfile();
      AppSnackBar.success("section_updated".tr);
    } catch (e) {
      AppSnackBar.error("section_update_failed".tr);
    } finally {
      savingBranding.value = false;
    }
  }

  // ── SECTION SAVE: SOCIAL MEDIA (requires at least one field filled) ──
  bool get hasAnySocialField =>
      facebookController.text.trim().isNotEmpty ||
      instagramController.text.trim().isNotEmpty ||
      linkedinController.text.trim().isNotEmpty ||
      twitterController.text.trim().isNotEmpty ||
      youtubeController.text.trim().isNotEmpty ||
      tiktokController.text.trim().isNotEmpty;

  Future<void> saveSocialMedia() async {
    if (!hasAnySocialField) {
      AppSnackBar.error("social_media_required".tr);
      return;
    }

    try {
      savingSocial.value = true;

      await SettingsApiClient.updateCompany({
        "facebook": facebookController.text.trim(),
        "instagram": instagramController.text.trim(),
        "linkedin": linkedinController.text.trim(),
        "twitter": twitterController.text.trim(),
        "youtube": youtubeController.text.trim(),
        "tiktok": tiktokController.text.trim(),
        "language": _currentLanguage,
      });

      await _refreshProfile();
      AppSnackBar.success("section_updated".tr);
    } catch (e) {
      AppSnackBar.error("section_update_failed".tr);
    } finally {
      savingSocial.value = false;
    }
  }

  // ── PASSWORD ──
  void toggleCurrent() => showCurrent.value = !showCurrent.value;
  void toggleNew() => showNew.value = !showNew.value;
  void toggleConfirm() => showConfirm.value = !showConfirm.value;

  

  Future<void> _refreshProfile() async {
    final profile = await MerchantService.profile();
    if (profile == null) return;
    await MerchantController.to.saveMerchant(profile);
    seedFromMerchant();
  }

  /// Clears every field and resettable state back to empty/default —
  /// called from onClose so a fresh controller instance never inherits
  /// stale text if the screen is re-entered later.
  void resetAll() {
    companyController.clear();
    tradeNameController.clear();
    siretController.clear();
    industryController.clear();
    phoneController.clear();
    newPasswordValue.value = "";
    streetController.clear();
    houseNumberController.clear();
    postalCodeController.clear();
    cityController.clear();
    countryController.clear();

    googleReviewController.clear();
    logoFile.value = null;
    existingLogoBase64.value = "";

    brandColorController.clear();
    secondaryColorController.clear();
    countryCodeController.clear();
    timezoneController.clear();
    currencyCode.value = "";
    language.value = "";

    facebookController.clear();
    instagramController.clear();
    linkedinController.clear();
    twitterController.clear();
    youtubeController.clear();
    tiktokController.clear();

    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    showCurrent.value = false;
    showNew.value = false;
    showConfirm.value = false;

    savingGeneralInfo.value = false;
    savingAddress.value = false;
    savingOnlinePresence.value = false;
    savingBranding.value = false;
    savingSocial.value = false;
    savingPassword.value = false;
  }

  @override
  void onClose() {
    resetAll();

    companyController.dispose();
    tradeNameController.dispose();
    siretController.dispose();
    industryController.dispose();
    phoneController.dispose();
    streetController.dispose();
    houseNumberController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
    countryController.dispose();
    googleReviewController.dispose();
    brandColorController.dispose();
    secondaryColorController.dispose();
    countryCodeController.dispose();
    timezoneController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    linkedinController.dispose();
    twitterController.dispose();
    youtubeController.dispose();
    tiktokController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}