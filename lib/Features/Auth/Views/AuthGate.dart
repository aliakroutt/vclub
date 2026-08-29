import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/API/Socket/MerchantRealtimeController.dart';
import 'package:vclub/API/SocketService.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Core/DeepLink/AppReadyState.dart';
import 'package:vclub/Core/Storage/Controllers/AgentController.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Core/Storage/Eneums.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Features/Auth/Services/AgentService.dart';
import 'package:vclub/Features/Auth/Services/ClientService.dart';
import 'package:vclub/Features/Auth/Services/MerchantService.dart';
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
        final profile = await ClientService.profile();
        if (profile != null) {
          await ClientController.to.saveClient(profile);
          _connectSocket();
          _finish(MainScreen());
        } else {
          _finish(const Login());
        }
        break;

      case UserRole.agent:
        final profile = await AgentService.profile();
        if (profile != null) {
          await AgentController.to.saveAgent(profile);
          _connectSocket();
          ensureMerchantRealtime();
          _finish(const MainScreenStaff());
        } else {
          _finish(const Login());
        }
        break;

      case UserRole.admin:
        final profile = await MerchantService.profile();
        if (profile != null) {
          await MerchantController.to.saveMerchant(profile);
          _connectSocket();
          ensureMerchantRealtime();
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

  void _connectSocket() {
    final token = TokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      Get.find<SocketService>().connect(token);
    }
  }

  void ensureMerchantRealtime() {
    if (!Get.isRegistered<MerchantRealtimeController>()) {
      Get.put(MerchantRealtimeController(), permanent: true);
    }
    MerchantRealtimeController.to.startListening();
  }

  void _finish(Widget target) {
    if (!mounted) return;
    setState(() {
      _target = target;
      _resolved = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        AppReadyState.markReady();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_resolved) {
      return const _AuthGateLoadingScreen();
    }

    return _target;
  }
}

/// Premium branded loading screen shown while AuthGate resolves the
/// session (checking stored token, fetching profile, connecting socket).
class _AuthGateLoadingScreen extends StatefulWidget {
  const _AuthGateLoadingScreen();

  @override
  State<_AuthGateLoadingScreen> createState() => _AuthGateLoadingScreenState();
}

class _AuthGateLoadingScreenState extends State<_AuthGateLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _pulseScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseScale = Tween(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    _ringOpacity = Tween(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final bgTop = isDark ? const Color(0xFF0E0E12) : const Color(0xFFFAFAFC);
    final bgBottom = isDark ? const Color(0xFF17171D) : Colors.white;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo mark with pulsing ring ──
                SizedBox(
                  width: size.width * 0.34,
                  height: size.width * 0.34,
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: _ringOpacity.value,
                            child: Transform.scale(
                              scale: _pulseScale.value,
                              child: Container(
                                width: size.width * 0.24,
                                height: size.width * 0.24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: size.width * 0.24,
                            height: size.width * 0.24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  Color.lerp(AppColors.primary, Colors.black, 0.2)!,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.35),
                                  blurRadius: 28,
                                  spreadRadius: -4,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Iconsax.crown_1,
                              color: Colors.white,
                              size: size.width * 0.11,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                SizedBox(height: size.height * 0.035),

                // ── App name ──
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppColors.primary,
                      Color.lerp(AppColors.primary, Colors.black, 0.25)!,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'VClub',
                    style: TextStyle(
                      fontSize: size.width * 0.075,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                // ── Slim indeterminate progress bar ──
                SizedBox(
                  width: size.width * 0.28,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
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