import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/ClientsProgramController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramStatModel.dart';

class StatsGrid extends GetView<ProgramClientsController> {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isStatsLoading.value) {
        return const _StatsGridSkeleton();
      }
      if (controller.statsError.value != null) {
        return _StatsGridError(onRetry: controller.fetchStats);
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: .82,
        ),
        itemBuilder: (_, index) => _StatCard(stat: controller.stats[index]),
      );
    });
  }
}

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: .82,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(.06)),
        ),
      ),
    );
  }
}

class _StatsGridError extends StatelessWidget {
  final VoidCallback onRetry;
  const _StatsGridError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          AppText('stats_load_error'.tr, color: Colors.grey),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: AppText('retry'.tr)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final ProgramStat stat;

  const _StatCard({
    required this.stat,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .018,
        vertical: size.width * .026,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              stat.icon,
              color: AppColors.primary,
              size: 14,
            ),
          ),
          SizedBox(height: size.width * .016),
          AppText(
            stat.value,
            fontSize: size.width * .034,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1),
          AppText(
            stat.title.tr,
            fontSize: size.width * .022,
            color: Colors.grey,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}