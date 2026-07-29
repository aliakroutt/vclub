import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:vclub/Features/Auth/Widgets/BackgroundCercle.dart';
import 'package:vclub/Features/Auth/Widgets/LanguageSelector.dart';
import 'package:vclub/Features/Auth/Widgets/LoginColumn.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async => false, // Disable system back button
        child: KeyboardDismissOnTap(child:  Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body:SingleChildScrollView( // ✅ scroll when keyboard appears
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          height: size.height, // ✅ full screen height
          child:  Stack(
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
            top: size.height * 0.3,
            left: size.width * 0.0,
            right: size.width * 0.0,
            child:  LoginColumn(),
          ),
        ],
      ))),
    )));
  }
}
