import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';


class TopClientsCard extends StatelessWidget {
  const TopClientsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = MerchantDashboardController.to;

    return Obx(() {
      final isLoading =
          controller.clientsLoading.value && !controller.initialLoaded.value;
      final hasError = controller.clientsError.value.isNotEmpty;

      final topClients = [...controller.clients]
        ..sort((a, b) => b.points.compareTo(a.points));
      final top3 = topClients.take(3).toList();

      return Container(
        padding: EdgeInsets.all(size.width * 0.045),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  width: size.width * 0.11,
                  height: size.width * 0.11,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.primary.withOpacity(0.12),
                  ),
                  child: const Icon(
                    Iconsax.people,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(width: size.width * 0.03),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "top_clients",
                        fontSize: size.width * 0.042,
                        fontWeight: FontWeight.w800,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        "by_accumulated_points",
                        fontSize: size.width * 0.032,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: size.height * 0.02),

            if (isLoading)
              ...List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.015),
                  child: _ClientTileSkeleton(size: size, isDark: isDark),
                ),
              )
            else if (hasError)
              _ClientsErrorState(
                size: size,
                isDark: isDark,
                onRetry: () => controller.fetchClients(),
              )
            else if (top3.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                child: Center(
                  child: AppText(
                    "no_clients_yet".tr,
                    fontSize: size.width * 0.034,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ...top3.map((c) {
                final name =
                    "${c.client.firstName} ${c.client.lastName}".trim();
                final displayName = name.isEmpty ? "guest".tr : name;
                final email = c.client.email;
                final points = c.points;

                final initials = _getInitials(displayName);

                return Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.015),
                  child: _ClientTile(
                    name: displayName,
                    email: email,
                    points: points,
                    initials: initials,
                    size: size,
                    isDark: isDark,
                  ),
                );
              }),
          ],
        ),
      );
    });
  }

  String _getInitials(String name) {
    final parts = name.split(" ").where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return "${parts[0][0]}${parts[1][0]}".toUpperCase();
  }
}

/// ================= CLIENT TILE =================

class _ClientTile extends StatelessWidget {
  final String name;
  final String email;
  final int points;
  final String initials;
  final Size size;
  final bool isDark;

  const _ClientTile({
    required this.name,
    required this.email,
    required this.points,
    required this.initials,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.03),
      ),
      child: Row(
        children: [
          /// AVATAR (INITIALS)
          Container(
            width: size.width * 0.12,
            height: size.width * 0.12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.2),
                ],
              ),
            ),
            child: Center(
              child: AppText(
                initials,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          SizedBox(width: size.width * 0.03),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  name,
                  fontSize: size.width * 0.038,
                  fontWeight: FontWeight.w700,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                AppText(
                  email,
                  fontSize: size.width * 0.031,
                  color: Colors.grey,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          /// POINTS
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.height * 0.008,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xFFFFC542).withOpacity(0.15),
            ),
            child: AppText(
              "points_pts".trParams({"count": points.toString()}),
              fontSize: size.width * 0.032,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFB300),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= SKELETON =================

class _ClientTileSkeleton extends StatelessWidget {
  final Size size;
  final bool isDark;

  const _ClientTileSkeleton({required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? Colors.white : Colors.black;

    return Container(
      height: size.height * 0.065,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: base.withOpacity(0.03),
      ),
      child: Row(
        children: [
          Container(
            width: size.width * 0.12,
            height: size.width * 0.12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: base.withOpacity(0.06),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size.width * 0.3,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: base.withOpacity(0.06),
                  ),
                ),
                SizedBox(height: size.height * 0.008),
                Container(
                  width: size.width * 0.4,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: base.withOpacity(0.05),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= ERROR STATE =================

class _ClientsErrorState extends StatelessWidget {
  final Size size;
  final bool isDark;
  final VoidCallback onRetry;

  const _ClientsErrorState({
    required this.size,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      child: Column(
        children: [
          AppText(
            "failed_load_clients".tr,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context)
                .textTheme
                .bodySmall
                ?.color
                ?.withOpacity(0.6),
          ),
          SizedBox(height: size.height * 0.012),
          GestureDetector(
            onTap: onRetry,
            child: AppText(
              "retry".tr,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}