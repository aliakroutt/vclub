import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Clients/Controllers/MerchantClientsController.dart';
import 'package:vclub/Features/Merchant/Clients/Models/ClientModel.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/ComposeNotificationController.dart';
import 'ComposeStyles.dart';

class ClientInlineSelector extends StatelessWidget {
  const ClientInlineSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final composeController = Get.find<ComposeNotificationController>();
    final clientsController = Get.find<ClientsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: composePanelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText("select_client".tr, fontSize: 12.5, fontWeight: FontWeight.w700),
          const SizedBox(height: 10),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.035),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Icon(Iconsax.search_normal_1, size: 15, color: Colors.grey.withOpacity(.6)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: clientsController.onSearchChanged,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: "search_client".tr,
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.withOpacity(.6)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: Obx(() {
              if (clientsController.isLoading.value) {
                return Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: AppColors.primary,
                    size: 34,
                  ),
                );
              }

              if (clientsController.hasError.value) {
                return Center(
                  child: AppText(
                    "failed_load_clients".tr,
                    fontSize: 12.5,
                    color: Colors.redAccent,
                  ),
                );
              }

              if (clientsController.clients.isEmpty) {
                return Center(
                  child: AppText(
                    "no_clients_found".tr,
                    fontSize: 12.5,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                  ),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (scroll) {
                  if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 100) {
                    clientsController.loadMore();
                  }
                  return false;
                },
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: clientsController.clients.length +
                      (clientsController.isLoadingMore.value ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    if (index == clientsController.clients.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: LoadingAnimationWidget.fourRotatingDots(
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      );
                    }

                    final ClientModel client = clientsController.clients[index];

                    return Obx(() {
                      final selected = composeController.selectedClient.value?.clientId == client.clientId;

                      return _ClientRow(
                        selected: selected,
                        name: client.fullName,
                        subtitle: client.email.isNotEmpty ? client.email : client.phone,
                        onTap: () => composeController.selectClient(client),
                      );
                    });
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  final bool selected;
  final String name;
  final String subtitle;
  final VoidCallback onTap;

  const _ClientRow({
    required this.selected,
    required this.name,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = name.trim().isNotEmpty
        ? name.trim().split(" ").map((e) => e.isNotEmpty ? e[0] : "").take(2).join().toUpperCase()
        : "?";

    return Material(
      color: selected
          ? AppColors.primary.withOpacity(.1)
          : (isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02)),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primary.withOpacity(.12),
                child: AppText(initials, fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(name, fontSize: 13, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis),
                    if (subtitle.isNotEmpty)
                      AppText(
                        subtitle,
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                selected ? Iconsax.tick_circle : Iconsax.tick_circle,
                size: 20,
                color: selected ? AppColors.primary : Colors.grey.withOpacity(.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}