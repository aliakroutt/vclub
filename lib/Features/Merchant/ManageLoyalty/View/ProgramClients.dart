import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/ClientsProgramController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/ClientItem.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/ClientsHeader.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/SearchClient.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/StatsClients.dart';

class ClientsProgram extends StatefulWidget {
  final String id ; 
  final String name ; 
  const ClientsProgram({super.key, required this.id, required this.name});

  @override
  State<ClientsProgram> createState() => _ClientsProgramState();
}

class _ClientsProgramState extends State<ClientsProgram> {
  late final ProgramClientsController controller;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    controller = Get.put(
      ProgramClientsController(
        programId: widget.id,
        initialProgramName: widget.name,
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<ProgramClientsController>();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
     final isRTL = Get.locale?.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child:  _circleButton(
                      context,
                      icon: isRTL
                          ? Iconsax.arrow_right_3_copy
                          : Iconsax.arrow_left_2_copy,
                      onTap: () => Get.back(),
                    
        ),
      )),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            controller: controller.scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.01),
                FadeSlide(delayMs: 250, child: HeaderSection()),
                SizedBox(height: size.height * 0.02),
                FadeSlide(delayMs: 300, child: StatsGrid()),
                SizedBox(height: size.height * 0.02),
                FadeSlide(
                  delayMs: 350,
                  child: PremiumSearchField(
                    controller: searchController,
                    onChanged: controller.onSearchChanged,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                FadeSlide(delayMs: 400, child: _ClientsList()),
                SizedBox(height: size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientsList extends GetView<ProgramClientsController> {
  const _ClientsList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isClientsLoading.value) {
        return const _ClientsListSkeleton();
      }

      if (controller.clientsError.value != null) {
        return _ClientsListError(onRetry: () => controller.fetchClients(reset: true));
      }

      if (controller.clients.isEmpty) {
        return const _ClientsListEmpty();
      }

      return Column(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            primary: false,
            shrinkWrap: true,
            itemCount: controller.clients.length,
            itemBuilder: (_, index) {
              final client = controller.clients[index];
              return ClientListItem(
                client: client,
                onTap: () {
                  // navigate to client details
                },
              );
            },
          ),
          if (controller.isLoadingMore.value)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
            ),
        ],
      );
    });
  }
}

class _ClientsListSkeleton extends StatelessWidget {
  const _ClientsListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _ClientsListError extends StatelessWidget {
  final VoidCallback onRetry;
  const _ClientsListError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Text('clients_load_error'.tr, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: Text('retry'.tr)),
          ],
        ),
      ),
    );
  }
}

class _ClientsListEmpty extends StatelessWidget {
  const _ClientsListEmpty();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * .05),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size.width * .22,
              height: size.width * .22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(.14),
                    AppColors.primary.withOpacity(.05),
                  ],
                ),
                border: Border.all(
                  color: AppColors.primary.withOpacity(.14),
                  width: 1.1,
                ),
              ),
              child: Icon(
                Iconsax.people_copy,
                size: size.width * .1,
                color: AppColors.primary.withOpacity(.55),
              ),
            ),
            SizedBox(height: size.height * .02),
            AppText(
              'no_clients_found'.tr,
              fontSize: size.width * .038,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white.withOpacity(.85) : const Color(0xFF1A1D29),
            ),
            SizedBox(height: size.height * .006),
            AppText(
              'no_clients_found_subtitle'.tr,
              fontSize: size.width * .032,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
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