import 'package:flutter/material.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class CampaignShimmerCard extends StatefulWidget {
  const CampaignShimmerCard({super.key});

  @override
  State<CampaignShimmerCard> createState() => _CampaignShimmerCardState();
}

class _CampaignShimmerCardState extends State<CampaignShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _block({double? width, double height = 12, double radius = 6}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 3, 0),
              end: Alignment(0 + _controller.value * 3, 0),
              colors: isDark
                  ? [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.14), Colors.white.withOpacity(0.06)]
                  : [Colors.black.withOpacity(0.05), Colors.black.withOpacity(0.11), Colors.black.withOpacity(0.05)],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _block(width: 44, height: 44, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(width: 120, height: 14),
                    const SizedBox(height: 8),
                    _block(width: 70, height: 10),
                  ],
                ),
              ),
              _block(width: 60, height: 20, radius: 20),
            ],
          ),
          const SizedBox(height: 14),
          _block(width: double.infinity, height: 10),
          const SizedBox(height: 16),
          Row(
            children: [
              _block(width: 70, height: 24, radius: 10),
              const SizedBox(width: 8),
              _block(width: 70, height: 24, radius: 10),
              const SizedBox(width: 8),
              _block(width: 70, height: 24, radius: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class CampaignEmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const CampaignEmptyState({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.18), AppColors.primary.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(Icons.campaign_rounded, size: 46, color: AppColors.primary),
            ),
            const SizedBox(height: 22),
            AppText('campaign_empty_title', fontSize: 17, fontWeight: FontWeight.w700),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: AppText(
                'campaign_empty_subtitle',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: onCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: AppText('new_campaign', fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class CampaignErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const CampaignErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: Icon(Icons.wifi_off_rounded, size: 42, color: Colors.red.shade400),
            ),
            const SizedBox(height: 20),
            AppText('campaign_error_title', fontSize: 16, fontWeight: FontWeight.w700),
            const SizedBox(height: 6),
            AppText(
              'campaign_error_subtitle',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: AppText('retry', fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}