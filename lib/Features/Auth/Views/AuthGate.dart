import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Core/DeepLink/AppReadyState.dart';
import 'package:vclub/Core/Storage/Controllers/AgentController.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Core/Storage/Eneums.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Features/Auth/Views/Login.dart';
import 'package:vclub/Features/Client/Main/Views/MainScreen.dart';
import 'package:vclub/Features/Merchant/Main/Controllers/MerchantMainController.dart';
import 'package:vclub/Features/Merchant/Main/View/MerchantMain.dart';
import 'package:vclub/Features/Staff/Main/View/MainScreenStaff.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _resolved = false;
  Widget _target = const Login();

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final isLoggedIn = TokenStorage.isLoggedIn;
    final role = TokenStorage.userRole;

    if (!isLoggedIn || role == null) {
      _finish(const Login());
      return;
    }

    switch (role) {
      case UserRole.client:
        await ClientController.to.loadClient();
        _finish(ClientController.to.isLogged ? MainScreen() : const Login());
        break;

      case UserRole.agent:
        await AgentController.to.loadAgent();
        _finish(AgentController.to.isLogged ? const MainScreenStaff() : const Login());
        break;

      case UserRole.admin:
        await MerchantController.to.loadMerchant();
        if (MerchantController.to.isLogged) {
          if (MerchantController.to.isFreePlan) {
            final mainController = Get.isRegistered<MerchantMainController>()
                ? Get.find<MerchantMainController>()
                : Get.put(MerchantMainController());
            mainController.selectIndex(11);
          }
          _finish(MainScreenMerchant());
        } else {
          _finish(const Login());
        }
        break;
    }
  }

  void _finish(Widget target) {
    if (!mounted) return;
    setState(() {
      _target = target;
      _resolved = true;
    });

    // Give the frame a moment to actually render the target screen before
    // signaling readiness, so any pending deep link pushes on top of a
    // screen the user has genuinely seen, not a blank transitional frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        AppReadyState.markReady();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_resolved) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _target;
  }
}