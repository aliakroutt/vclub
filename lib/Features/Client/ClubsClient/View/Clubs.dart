import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/AppLoader.dart';
import 'package:vclub/Features/Client/Cards/Controllers/ClientCradsController.dart';
import 'package:vclub/Features/Client/ClubsClient/Controller/ClientClubsController.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/MerchantModel.dart';
import 'package:vclub/Features/Client/ClubsClient/View/Widgets/ClubHeader.dart';
import 'package:vclub/Features/Client/ClubsClient/View/Widgets/ClubProgramSection.dart';
import 'package:vclub/Features/Client/ClubsClient/View/Widgets/ClubProgramSheet.dart';
import 'package:vclub/Features/Client/ClubsClient/View/Widgets/ClubRoleActionsCard.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/QRScanner/ProgramClientApi.dart';
import 'package:vclub/Features/Client/QRScanner/View/JoinClubsDialog.dart';

enum ClubViewerRole { client, ownerMerchant, otherMerchant, staff, guest }

/// Arguments needed to open [ClubScreen].
class ClubScreenArgs {
  final String clubSlug;
  final ClubViewerRole role;

  const ClubScreenArgs({required this.clubSlug, required this.role});
}

class ClubScreen extends StatefulWidget {
  final String clubSlug;
  final ClubViewerRole role;

  const ClubScreen({super.key, required this.clubSlug, required this.role});

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  final CardsController controller = Get.put(CardsController(), tag: 'club');

  @override
  void initState() {
    super.initState();
    controller.fetchPrograms(widget.clubSlug);
    if( widget.role == ClubViewerRole.client) {
     controller.fetchClientCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';
    return Scaffold(
      // backgroundColor: them,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        leading: Padding(
          padding: isRTL
              ? EdgeInsets.only(right: 20)
              : EdgeInsets.only(left: 20),
          child: _circleButton(
            context,
            icon: isRTL
                ? Iconsax.arrow_right_3_copy
                : Iconsax.arrow_left_2_copy,
            onTap: () => Get.back(),
          ),
        ),
        // actions: [
        //   ..._appBarActionsForRole(widget.role),
        //   const SizedBox(width: 20),
        // ],
      ),
      body: Obx(() {
        if (controller.isLoadingPrograms.value) {
          return Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: AppColors.primary,
              size: 52,
            ),
          );
        }

        if (controller.programsError.value.isNotEmpty) {
          return _buildError(controller.programsError.value);
        }

        final merchant = controller.merchant.value;
        if (merchant == null) {
          return const SizedBox.shrink();
        }

        return  Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + kToolbarHeight + 4,
                  16,
                  4,
                ),
                child: ClubHeader(merchant: merchant),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: ClubRoleActionCard(
                  role: widget.role,
                  onLogin: () {
                    // TODO: navigate to login screen
                  },
                  onSignup: () {
                    // TODO: navigate to signup screen
                  },
                  onViewMyCards: () {
                    // TODO: navigate to merchant's cards/dashboard screen
                  },
                ),
              ),
              Expanded(
                child: _buildBodyForRole(role: widget.role, merchant: merchant),
              ),
            ],
          
        );
      }),
    );
  }

  Widget _circleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(.3)
                  : Colors.black.withOpacity(.2),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _buildBodyForRole({
    required ClubViewerRole role,
    required Merchant merchant,
  }) {
    switch (role) {
      case ClubViewerRole.client:
        return _buildClientView(merchant);
      case ClubViewerRole.ownerMerchant:
        return _buildOwnerMerchantView(merchant);
      case ClubViewerRole.otherMerchant:
        return _buildOtherMerchantView(merchant);
      case ClubViewerRole.staff:
        return _buildStaffView(merchant);
      case ClubViewerRole.guest:
        return _buildGuestView(merchant);
    }
  }

  Set<String> get _joinedProgramIds =>
      controller.cards.map((card) => card.program.id).toSet();

  void _onProgramDetails(LoyaltyProgram program) {
    showClubProgramDetailsSheet(
      context,
      program: program,
      currencyCode: controller.merchant.value?.currencyCode,
    );
  }

  Future<void> _onProgramJoin(LoyaltyProgram program) async {
    AppLoader.show();
    final cards_controller = ClientCardsController.to;
    final dashcontroller = ClientDashboardController.to;
    final result = await ProgramApiClient.joinProgram(
      clubSlug: widget.clubSlug,
      programSlug: program.slug,
    );
    if (result.joined) {
      await controller.fetchPrograms(widget.clubSlug);
      await cards_controller.fetchCards();
      await dashcontroller.fetchCards();
      await controller.fetchClientCards();
      AppLoader.hide();
      if (!mounted) return;
      JoinClubDialogs.showSuccess();
    } else {
      AppLoader.hide();
      _failAndClose(result.message ?? "join_failed_generic".tr);
    }
  }

  void _failAndClose(String message) {
    if (mounted) JoinClubDialogs.showError(message);
  }
  // ---- Per-role bodies ----

   Widget _buildClientView(Merchant merchant) {
    return ClubProgramsSection(
      programs: merchant.programs,
      role: widget.role,
      joinedProgramIds: _joinedProgramIds,
      onDetails: _onProgramDetails,
      onJoin: _onProgramJoin,
    );
  }
 
  Widget _buildOwnerMerchantView(Merchant merchant) {
    return ClubProgramsSection(
      programs: merchant.programs,
      role: widget.role,
      onDetails: _onProgramDetails,
    );
  }
 
  Widget _buildOtherMerchantView(Merchant merchant) {
    return ClubProgramsSection(
      programs: merchant.programs,
      role: widget.role,
      onDetails: _onProgramDetails,
    );
  }
 
  Widget _buildStaffView(Merchant merchant) {
    return ClubProgramsSection(
      programs: merchant.programs,
      role: widget.role,
      onDetails: _onProgramDetails,
    );
  }
 
  Widget _buildGuestView(Merchant merchant) {
    return ClubProgramsSection(
      programs: merchant.programs,
      role: widget.role,
      onDetails: _onProgramDetails,
    );
  }

  Widget _buildError(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AppText(
          message,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
