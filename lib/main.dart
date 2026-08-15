import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/Configs/Theme/app_theme.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Configs/Translations/app_translations.dart';
import 'package:vclub/Configs/Translations/language_service.dart';
import 'package:vclub/Core/Storage/Controllers/AgentController.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Features/Auth/Controllers/ForgetPasswordController.dart';
import 'package:vclub/Features/Auth/Controllers/SignUp_Controller.dart';
import 'package:vclub/Features/Auth/Views/AuthGate.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Notifications/Controllers/ClientNotificationsController.dart';
import 'package:vclub/Features/Client/Rewards/Controllers/RewardsClientController.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/MerchantProgramsController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/ComposeNotificationController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/MerchantNotificationsController.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/MerchantNotificationsListController.dart';
import 'package:vclub/Core/DeepLink/DeepLinkService.dart';
Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.init();
  await ApiClient.init();
  
  print('1. Binding initialized');
  final languageService = Get.put(LanguageService());
  print('2. LanguageService created');
  final locale = await languageService.getLocale();
  print('3. Locale obtained: $locale');
  final themeService = Get.put(ThemeService());
  print('4. ThemeService created');
  final themeMode = await themeService.initTheme();
  print('5. ThemeMode obtained: $themeMode');
  runApp(MyApp(locale: locale, themeMode: themeMode));
  print('6. runApp called');
   WidgetsBinding.instance.addPostFrameCallback((_) {
    DeepLinkService.instance.init();
  });
}

class MyApp extends StatelessWidget {
  final Locale locale;
  final ThemeMode themeMode;
  const MyApp({super.key, required this.locale, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // Allow only portrait orientation
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light, // iOS
        systemNavigationBarColor: Colors.white,
      ),
    );
    return GetMaterialApp(
        
       initialBinding: BindingsBuilder(() {
        Get.put(ForgotPasswordController(), permanent: true);
        Get.put(ClientController(), permanent: true);
        Get.put(MerchantController(), permanent: true);
        Get.put(ClientDashboardController(), permanent: true);
        Get.put(SignUpController(), permanent: true);
        Get.put(NotificationsController(), permanent: true);
        Get.put(GoogleReviewController(), permanent: true); 
        Get.put(MerchantDashboardController(), permanent: true);  
        Get.put(MerchantProgramsController(), permanent: true); 
        Get.put(MerchantNotificationsController(), permanent: true);
        Get.put(ComposeNotificationController(), permanent: true);
        Get.put(MerchantNotificationsListController(), permanent: true);
        Get.put(AgentController(), permanent: true);
      }),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final isArabic = Get.locale?.languageCode == 'ar';

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: const AuthGate(),
    );
  }
}
