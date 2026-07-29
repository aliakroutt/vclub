import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Clients/Controllers/MerchantClientsController.dart';
import 'package:vclub/Features/Merchant/Clients/View/ClientDetailsScreen.dart';
import 'package:vclub/Features/Merchant/Clients/View/Widgets/ClientCard.dart';
import 'package:vclub/Features/Merchant/Clients/View/Widgets/ClientCardShimmer.dart';
import 'package:vclub/Features/Merchant/Clients/View/Widgets/ClientEmptyState.dart';
import 'package:vclub/Features/Merchant/Clients/View/Widgets/ClientsErrorState.dart';
import 'package:vclub/Features/Merchant/Clients/View/Widgets/ClientsTabs.dart';
import 'package:vclub/Features/Merchant/Clients/View/Widgets/HeaderClients.dart';

class MerchantClients extends StatefulWidget {
  const MerchantClients({super.key});

  @override
  State<MerchantClients> createState() => _MerchantClientsState();
}

class _MerchantClientsState extends State<MerchantClients> {
  final searchController = TextEditingController();
  final controller = Get.put(ClientsController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    searchController.dispose();
    controller.resetData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return KeyboardDismissOnTap(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              color: AppColors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.01),
                        Align(
                          alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                          child: FadeSlide(
                            delayMs: 200,
                            child: AppText("clients", fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Align(
                          alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                          child: FadeSlide(
                            delayMs: 250,
                            child: AppText(
                              'clients_subtitle',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        FadeSlide(
                          delayMs: 300,
                          child: Obx(
                            () => ClientsHeader(
                              searchController: searchController,
                              onAdd: () {},
                              onChanged: controller.onSearchChanged,
                              clientCount: controller.totalClients.value,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        FadeSlide(
                          delayMs: 350,
                          child: Obx(
                            () => ClientsTabBar(
                              selectedTab: controller.selectedTab.value,
                              onTabChanged: controller.changeTab,
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                      ],
                    ),
                  ),

                  Obx(() {
                    if (controller.isLoading.value) {
                      return  SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const ClientCardShimmer(),
                          childCount: 6,
                        ),
                      );
                    }

                    if (controller.hasError.value) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: ClientsErrorState(onRetry: controller.refresh),
                      );
                    }

                    if (controller.clients.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: ClientsEmptyState(
                          isSearching: controller.searchQuery.value.isNotEmpty,
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == controller.clients.length) {
                            return controller.isLoadingMore.value
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: ClientCardShimmer(),
                                  )
                                : const SizedBox.shrink();
                          }
                          final client = controller.clients[index];
                          return ClientCard(
                            client: client,
                            onTap: () => AppNavigator.to(ClientDetailScreen(client: client)),
                          );
                        },
                        childCount: controller.clients.length + (controller.hasMore ? 1 : 0),
                      ),
                    );
                  }),

                  SliverToBoxAdapter(child: SizedBox(height: size.height * 0.15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}