import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/LoyaltyProgramModel.dart' show ProgramMode;
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramsModel.dart';


extension ProgramModelDisplay on ProgramModel {
  ProgramMode get uiMode {
    switch (mode.toLowerCase()) {
      case 'stamps':
        return ProgramMode.stamps;
      case 'cashback':
        return ProgramMode.cashback;
      case 'points':
      default:
        return ProgramMode.points;
    }
  }

  String get title => name;

  bool get isActive => active && status.toLowerCase() == 'active';

  String get subtitle {
    switch (uiMode) {
      case ProgramMode.stamps:
        return "$stampsPerVisit ${"stamps_per_visit_merchant".tr} • "
            "$stampsPerReward ${"stamps_to_reward_merchant".tr}";
      case ProgramMode.cashback:
        final pct = cashbackPercent % 1 == 0
            ? cashbackPercent.toStringAsFixed(0)
            : cashbackPercent.toStringAsFixed(1);
        return "$pct% ${"cashback_merchant".tr}";
      case ProgramMode.points:
        final pts = pointsPerCurrencyUnit % 1 == 0
            ? pointsPerCurrencyUnit.toStringAsFixed(0)
            : pointsPerCurrencyUnit.toStringAsFixed(1);
        return "$pts ${"pts_per_unit_merchant".tr}";
    }
  }
}