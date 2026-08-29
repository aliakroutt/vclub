import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/MyProfile/View/Controllers/UpdateAvatarController.dart';
import 'package:vclub/Features/Client/MyProfile/View/UpdateProfile/UpdateClientScreen.dart';
import 'package:vclub/Features/Client/MyProfile/View/Widgets/ChangePasswordSheet.dart';
import 'package:vclub/Features/Client/MyProfile/View/Widgets/ClubsSection.dart';
import 'package:vclub/Features/Client/MyProfile/View/Widgets/ProfileActions.dart';
import 'package:vclub/Features/Client/MyProfile/View/Widgets/ProfileHeader.dart';
import 'package:vclub/Features/Client/MyProfile/View/Widgets/ProfileInfoCard.dart';
import 'package:vclub/Features/Client/MyProfile/View/Widgets/ProfileStats.dart';
import 'package:vclub/Features/Client/MyProfile/View/Widgets/ScrollReveal.dart';

/// Profile screen, reorganized as grouped sections (summary card → stats →
/// account actions → contact info → clubs) instead of a single parallax
/// hero — the layout used by Revolut / Wise / N26 "Account" tabs. Every
/// section is flat, self-contained, and reveals with the same staggered
/// scroll-in animation for a consistent premium rhythm.
class ProfileClient extends StatefulWidget {
  const ProfileClient({super.key});

  @override
  State<ProfileClient> createState() => _ProfileClientState();
}

class _ProfileClientState extends State<ProfileClient> {
  final controller = Get.find<ClientController>();
  final dashcontroller = ClientDashboardController.to;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<UpdateAvatarController>()) {
    Get.put(UpdateAvatarController());
  }
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      dashcontroller.fetchStats(),
      dashcontroller.fetchCards(),
    ]);
  }

  Future<void> _pickAndUploadAvatar() async {
  final ImagePicker picker = ImagePicker();

  final XFile? picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
    maxWidth: 1000,
  );

  if (picked == null) return;

  final controller = Get.find<UpdateAvatarController>();
  await controller.uploadAvatar(File(picked.path));
}

  void _onEditProfile() {
    AppNavigator.to(EditProfileScreen());
   
  }

  void _onChangePassword() {
  showChangePasswordSheet(context);
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sectionGap = (size.height * 0.028).clamp(20.0, 30.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // SliverAppBar(
            //   pinned: true,
            //   floating: false,
            //   elevation: 0,
            //   scrolledUnderElevation: 0,
            //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            //   surfaceTintColor: Colors.transparent,
            //   centerTitle: false,
            //   title: AppText("my_profile".tr, fontSize: 19, fontWeight: FontWeight.w800),
            // ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ---- Profile summary ----
                  Obx(() {
                    final client = controller.client.value;
                    if (client == null) {
                      return const _CardSkeleton(height: 220);
                    }
                    return ScrollReveal(
                      controller: _scrollController,
                      index: 0,
                      child: ProfileSummaryCard(
                        client: client,
                        onChangeAvatar: _pickAndUploadAvatar,
                      ),
                    );
                  }),

                  SizedBox(height: sectionGap),

                  // ---- Stats ----
                  Obx(() => ScrollReveal(
                        controller: _scrollController,
                        index: 1,
                        child: ProfileStatsRow(
                          stats: dashcontroller.stats.value,
                          isLoading: dashcontroller.statsLoading.value,
                        ),
                      )),

                  SizedBox(height: sectionGap),

                  // ---- Account actions ----
                  _SectionHeader(title: "account".tr, index: 2, scrollController: _scrollController),
                  SizedBox(height: size.height * 0.014),
                  ScrollReveal(
                    controller: _scrollController,
                    index: 2,
                    child: ProfileActionsCard(
                      onEditInfo: _onEditProfile,
                      onChangePassword: _onChangePassword,
                      onChangePhoto: _pickAndUploadAvatar,
                    ),
                  ),

                  SizedBox(height: sectionGap),

                  // ---- Contact information ----
                  _SectionHeader(title: "contact_information".tr, index: 3, scrollController: _scrollController),
                  SizedBox(height: size.height * 0.014),
                  Obx(() {
                    final client = controller.client.value;
                    if (client == null) {
                      return const _CardSkeleton(height: 168);
                    }
                    return ScrollReveal(
                      controller: _scrollController,
                      index: 3,
                      child: ProfileInfoCard(client: client),
                    );
                  }),

                  SizedBox(height: sectionGap),

                  // ---- Clubs ----
                  _SectionHeader(title: "clubs_joined".tr, index: 4, scrollController: _scrollController),
                  SizedBox(height: size.height * 0.014),
                  Obx(() => ClubsSection(
                        cards: dashcontroller.cards,
                        isLoading: dashcontroller.cardsLoading.value,
                        scrollController: _scrollController,
                      )),
                      SizedBox(height: size.height * 0.15),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small section label shared by every group, matching the settings-style
/// grouped layout ("ACCOUNT", "CONTACT INFORMATION", "CLUBS JOINED"...).
class _SectionHeader extends StatelessWidget {
  final String title;
  final int index;
  final ScrollController scrollController;

  const _SectionHeader({required this.title, required this.index, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      controller: scrollController,
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AppText(
          title.toUpperCase(),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.withOpacity(0.85),
        ),
      ),
    );
  }
}

// class _SheetActionTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   const _SheetActionTile({required this.icon, required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Material(
//       color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//           child: Row(
//             children: [
//               Container(
//                 width: 42,
//                 height: 42,
//                 decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(13)),
//                 child: Icon(icon, size: 19, color: AppColors.primary),
//               ),
//               const SizedBox(width: 14),
//               Expanded(child: AppText(label, fontSize: 14.5, fontWeight: FontWeight.w600)),
//               Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey.withOpacity(0.6)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _CardSkeleton extends StatelessWidget {
  final double height;
  const _CardSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
      ),
    );
  }
}