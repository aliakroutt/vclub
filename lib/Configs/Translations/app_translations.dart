import 'package:get/get.dart';
import 'package:vclub/Configs/Translations/ar_ar.dart';
import 'package:vclub/Configs/Translations/en_us.dart';
import 'package:vclub/Configs/Translations/fr_fr.dart';



class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'fr_FR': frFR,
        'ar_AR': arAR,
      };
}