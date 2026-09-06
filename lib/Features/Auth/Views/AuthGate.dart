import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/API/Socket/MerchantRealtimeController.dart';
import 'package:vclub/API/SocketService.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
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
  bool _hasError = false;
  Widget _target = const Login();

  static const _profileTimeout = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    if (mounted) setState(() => _hasError = false);

    final isLoggedIn = TokenStorage.isLoggedIn;
    final role = TokenStorage.userRole;

    if (!isLoggedIn || role == null) {
      _finish(const Login());
      return;
    }

    try {
      switch (role) {
        case UserRole.client:
          final profile = await ClientService.profile().timeout(_profileTimeout);
          if (profile != null) {
            await ClientController.to.saveClient(profile);
            _connectSocket();
            _finish(MainScreen());
          } else {
            _finish(const Login());
          }
          break;

        case UserRole.agent:
          final profile = await AgentService.profile().timeout(_profileTimeout);
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
          final profile = await MerchantService.profile().timeout(_profileTimeout);
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
    } on TimeoutException {
      _showError();
    } catch (e) {
      // Any network/unexpected failure — don't silently drop the user to
      // Login (which would look like a session expiry); show a retryable
      // error instead, since the session itself is likely still valid.
      _showError();
    }
  }

  void _showError() {
    if (!mounted) return;
    setState(() {
      _hasError = true;
      _resolved = true;
    });
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
      _hasError = false;
      _resolved = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        AppReadyState.markReady();
      });
    });
  }

  void _retry() {
    setState(() {
      _resolved = false;
      _hasError = false;
    });
    _resolve();
  }

  @override
  Widget build(BuildContext context) {
    if (!_resolved) {
      return const _AuthGateLoadingScreen();
    }

    if (_hasError) {
      return _AuthGateErrorScreen(onRetry: _retry);
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

/// Shown when session resolution fails — network error, timeout, or any
/// unexpected exception while fetching the profile. Offers a retry
/// instead of silently bouncing to Login, since the session may still be
/// valid and the problem is purely connectivity.
class _AuthGateErrorScreen extends StatefulWidget {
  final VoidCallback onRetry;
  const _AuthGateErrorScreen({required this.onRetry});

  @override
  State<_AuthGateErrorScreen> createState() => _AuthGateErrorScreenState();
}

class _AuthGateErrorScreenState extends State<_AuthGateErrorScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideUp = Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(_fadeIn);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    setState(() => _retrying = true);
    // Small delay so the button's loading state is visibly perceptible
    // even on a fast local failure, avoiding an instant flicker.
    await Future.delayed(const Duration(milliseconds: 300));
    widget.onRetry();
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Icon badge ──
                      Container(
                        width: size.width * 0.24,
                        height: size.width * 0.24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.redAccent,
                              Color.lerp(Colors.redAccent, Colors.black, 0.2)!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.3),
                              blurRadius: 24,
                              spreadRadius: -4,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Iconsax.wifi_square,
                          color: Colors.white,
                          size: size.width * 0.1,
                        ),
                      ),

                      SizedBox(height: size.height * 0.035),

                      AppText(
                        "connection_error_title".tr,
                        fontSize: size.width * 0.052,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: size.height * 0.012),

                      AppText(
                        "connection_error_subtitle".tr,
                        fontSize: size.width * 0.036,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),

                      SizedBox(height: size.height * 0.045),

                      // ── Retry button ──
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _retrying ? null : _handleRetry,
                            child: Center(
                              child: _retrying
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Iconsax.refresh, size: 19, color: Colors.white),
                                        const SizedBox(width: 8),
                                        AppText(
                                          "retry".tr,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}