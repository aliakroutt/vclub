import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vclub/Features/Auth/Controllers/SignUp_Controller.dart';
import 'package:vclub/Features/Auth/Widgets/BackgroundCercle.dart';
import 'package:vclub/Features/Auth/Widgets/Client/ClientData.dart';
import 'package:vclub/Features/Auth/Widgets/LanguageSelector.dart';
import 'package:vclub/Features/Auth/Widgets/Merchant/MerchantChoosePlan.dart';
import 'package:vclub/Features/Auth/Widgets/RoleAnimatedSwitcher.dart';
import 'package:vclub/Features/Auth/Widgets/RoleTabSelector.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final controller = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return KeyboardDismissOnTap(
      child:   Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: [
                Positioned(
                  top: -size.height * 0.05,
                  right: -size.width * 0.25,
                  child: BackgroundCircle(
                    size: size.width * 0.7,
                    innerSize: size.width * 0.45,
                  ),
                ),

                Positioned(
                  bottom: -size.height * 0.05,
                  left: -size.width * 0.20,
                  child: BackgroundCircle(
                    size: size.width * 0.55,
                    innerSize: size.width * 0.35,
                  ),
                ),

                Positioned(
                  top: size.height * 0.07,
                  right: size.width * 0.08,
                  child: LanguageSelector(),
                ),

                Positioned(
                  top: size.height * 0.15,
                  left: 0,
                  right: 0,
                  child: RoleTabSelector(
                    selected: controller.selectedRole,
                    onChanged: controller.changeRole,
                  ),
                ),

                /// 👇 THIS IS THE MAGIC PART
                Positioned(
                  top: size.height * 0.24,
                  left: 0,
                  right: 0,
                  child: RoleAnimatedSwitcher(
                    role: controller.selectedRole,

                    clientWidget: const ClientData(),
                    merchantWidget: const MerchantSignUpForm(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}