import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Compains/Controllers/CampaignController.dart';
import 'package:vclub/Features/Merchant/Compains/View/widgets/campaign_card.dart';
import 'package:vclub/Features/Merchant/Compains/View/widgets/campaign_states.dart';
import 'package:vclub/Features/Merchant/Compains/View/widgets/create_campaign_sheet.dart';
import 'package:vclub/Features/Merchant/Compains/View/widgets/delete_campaign_dialog.dart';


class Compains extends StatefulWidget {
  const Compains({super.key});

  @override
  State<Compains> createState() => _CompainsState();
}

class _CompainsState extends State<Compains> {
  final CampaignController controller = Get.put(CampaignController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

 Future<void> _confirmDelete(String id, String name) async {
  await Get.dialog<bool>(
    DeleteCampaignDialog(
      name: name,
      onConfirm: () => controller.deleteCampaign(id),
    ),
    barrierDismissible: false,
  );
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';
    final isTablet = size.width > 600;

    return KeyboardDismissOnTap(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.01),

                Align(
                  alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  child: FadeSlide(
                    delayMs: 200,
                    child: AppText("campaigns", fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),

                SizedBox(height: size.height * 0.01),

                Align(
                  alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  child: FadeSlide(
                    delayMs: 250,
                    child: AppText(
                      'campaigns_subtitle',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // New Campaign button
                FadeSlide(
                  delayMs: 300,
                  child: SizedBox(
                    width: isTablet ? 240 : double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showCreateCampaignSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: AppText(
                        'new_campaign',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // List
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return ListView.builder(
                        
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (_, __) => const CampaignShimmerCard(),
                      );
                    }

                    if (controller.hasError.value) {
                      return CampaignErrorState(onRetry: controller.refresh);
                    }

                    if (controller.campaigns.isEmpty) {
                      return CampaignEmptyState(onCreate: () {
                       showCreateCampaignSheet(context);
                      });
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: controller.refresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(bottom: size.height * 0.15),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: controller.campaigns.length + (controller.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= controller.campaigns.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.4),
                                ),
                              ),
                            );
                          }

                          final campaign = controller.campaigns[index];
                          return FadeSlide(
                            delayMs: 50 * (index % 8),
                            child: CampaignCard(
                              campaign: campaign,
                              isDeleting: controller.isDeletingId.value == campaign.id,
                              onDelete: () => _confirmDelete(campaign.id, campaign.name),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}