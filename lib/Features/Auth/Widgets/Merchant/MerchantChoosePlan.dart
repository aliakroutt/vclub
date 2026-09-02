import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Features/Auth/Controllers/MerchantSignUpController.dart';
import 'package:vclub/Features/Auth/Widgets/AuthSignInText.dart';
import 'package:vclub/Features/Auth/Widgets/Merchant/MerchantDetailsForm.dart';
import 'package:vclub/Features/Auth/Widgets/Merchant/PlanCard.dart';
import 'package:vclub/Features/Auth/Widgets/NextButton.dart';

class MerchantSignUpForm extends StatelessWidget {
  const MerchantSignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MerchantSignUpController());
    final size = MediaQuery.of(context).size;

  final plans = [
  {
    "title": "starter",
    "price": "9.90€",
    "duration": "month".tr,
    "features": [
      "plan_limited_loyalty_program",
      "plan_qr_code",
      "plan_clients_200_max",
      "plan_statistics",
    ],
    "popular": false,
    "disabled": false,
    "inherited": null,
  },
  {
    "title": "business",
    "price": "19.90€",
    "duration": "month".tr,
    "features": [
      "plan_unlimited_loyalty_program",
      "plan_unlimited_clients",
      "plan_lucky_wheel",
      "plan_google_reviews",
    ],
    "popular": true,
    "disabled": false,
    "inherited": "everything_in_starter".tr,
  },
  {
    "title": "premium",
    "price": "29.90€",
    "duration": "month".tr,
    "features": [
      "plan_multi_access_employees",
      "plan_marketing_campaigns",
    ],
    "popular": false,
    "disabled": false,
    "inherited": "everything_in_starter_business".tr,
  },
  // {
  //   "title": "quote",
  //   "price": "custom".tr,
  //   "duration": "",
  //   "features": [
  //     "plan_custom_needs",
  //     "plan_custom_integration",
  //     "plan_dedicated_support",
  //     "plan_custom_development",
  //   ],
  //   "popular": false,
  //   "disabled": true,
  //   "inherited": null,
  // },
];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
      child: Column(
        key: const ValueKey("merchant"),
        children: [
          /// TITLE
          AppText(
            "choose_your_plan",
            textAlign: TextAlign.center,
            fontSize: size.width * 0.06,
            fontWeight: FontWeight.w700,
          ),

          SizedBox(height: size.height * 0.01),

          /// SUBTITLE
          AppText(
            "start_free_and_scale",
            textAlign: TextAlign.center,
            fontSize: size.width * 0.036,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
            height: 1.4,
          ),

          SizedBox(height: size.height * 0.01),

          /// LIST + BUTTON + SIGN IN
          SizedBox(
            height: size.height * 0.65,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: plans.length + 2,
              separatorBuilder: (_, __) =>
                  SizedBox(height: size.height * 0.015),
              itemBuilder: (context, index) {
                /// PLANS
              if (index < plans.length) {
  final plan = plans[index];
  final isDisabled = plan["disabled"] as bool;

  return Obx(
    () => PlanCard(
      title: plan["title"].toString().tr,
      price: plan["price"].toString(),
      duration: plan["duration"].toString(),
      features:
          (plan["features"] as List)
              .map((e) => e.toString().tr)
              .toList(),
      isPopular: plan["popular"] as bool,
      isDisabled: isDisabled,
      comingSoonLabel: isDisabled ? "coming_soon".tr : null,
      inheritedLabel: plan["inherited"] as String?,
      isSelected:
          controller.selectedPlanIndex.value == index && !isDisabled,
      onTap: isDisabled ? null : () => controller.selectPlan(index),
      showSmsOption: !isDisabled, // hide entirely on the disabled "quote" plan
      smsSelected: controller.includeSmsAddon.value,
      onSmsToggle: controller.toggleSmsAddon,
    ),
  );
}

                /// NEXT BUTTON
                if (index == plans.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: size.height * 0.015),
                    child: Obx(
                      () => NextButton(
                        text: "next",
                        isEnabled: controller.hasSelectedPlan,
                        width: size.width,
                        onTap: () {
                          AppNavigator.to(MerchantDetailsForm());
                         
                        },
                      ),
                    ),
                  );
                }

                /// SIGN IN TEXT
                return AuthSignInText(
                  onTap: () => Get.back(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}