import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vclub/Core/DeepLink/AppReadyState.dart';
import 'package:vclub/Core/Storage/Controllers/AgentController.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Core/Storage/Eneums.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Features/Client/ClubsClient/View/Clubs.dart';


class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Uri? _lastHandled;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // 1. Cold start: app was launched directly from a tapped link.
    // Wait for the app's initial destination (Login or main screen) to be
    // shown first, THEN push the club screen on top of it.
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await AppReadyState.ready;
        await _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint("⚠️ DeepLinkService: failed to read initial link: $e");
    }

    // 2. App already running (foreground/background): link tapped again.
    // The app is already showing a screen, so push immediately.
    _sub = _appLinks.uriLinkStream.listen(
      (uri) async {
        if (!AppReadyState.isReady) {
          await AppReadyState.ready;
        }
        await _handleUri(uri);
      },
      onError: (e) => debugPrint("⚠️ DeepLinkService stream error: $e"),
    );
  }

  Future<void> _handleUri(Uri uri) async {
    if (_lastHandled == uri) return;
    _lastHandled = uri;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return;

    final slug = segments.first;
    await _navigateToClub(slug);
  }

  Future<void> _navigateToClub(String slug) async {
    final role = await resolveViewerRoleFor(slug);
    await _waitForNavigatorReady();

    // Pushes on top of whatever screen is currently showing (Login for a
    // guest, the merchant dashboard for a logged-in admin, etc.).
    Get.to(() => ClubScreen(clubSlug: slug, role: role));
  }

  /// Exposed publicly so LoginController (or a signup flow) can resolve
  /// the viewer's role for a pending club slug after authenticating.
  Future<ClubViewerRole> resolveViewerRoleFor(String slug) async {
    final isLoggedIn = TokenStorage.isLoggedIn;
    final role = TokenStorage.userRole;

    if (!isLoggedIn || role == null) {
      return ClubViewerRole.guest;
    }

    switch (role) {
      case UserRole.client:
        return ClubViewerRole.client;

      case UserRole.admin:
        if (!MerchantController.to.isLogged) {
          await MerchantController.to.loadMerchant();
        }
        final companySlug = MerchantController.to.merchant.value?.company?.slug;
        return companySlug == slug ? ClubViewerRole.ownerMerchant : ClubViewerRole.otherMerchant;

      case UserRole.agent:
        if (!AgentController.to.isLogged) {
          await AgentController.to.loadAgent();
        }
        final companySlug = AgentController.to.agent.value?.company?.slug;
        return companySlug == slug ? ClubViewerRole.staff : ClubViewerRole.guest;
    }
  }

  Future<void> _waitForNavigatorReady() async {
    var attempts = 0;
    while (Get.key.currentState == null && attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 50));
      attempts++;
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}