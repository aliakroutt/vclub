import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Compains/Models/CampaignModel.dart';

class CampaignTypeMeta {
  final IconData icon;
  final Color color;
  CampaignTypeMeta(this.icon, this.color);
}

CampaignTypeMeta getCampaignTypeMeta(String type) {
  switch (type) {
    case 'promotion':
      return CampaignTypeMeta(Iconsax.discount_shape_copy, const Color(0xFF6C5CE7));
    case 'points_multiplier':
      return CampaignTypeMeta(Iconsax.chart_success_copy, const Color(0xFF00B894));
    case 'bonus_points':
      return CampaignTypeMeta(Iconsax.gift_copy, const Color(0xFFE17055));
    case 'discount':
      return CampaignTypeMeta(Iconsax.percentage_square_copy, const Color(0xFF0984E3));
    case 'free_reward':
      return CampaignTypeMeta(Iconsax.crown_copy, const Color(0xFFD63031));
    case 'birthday':
      return CampaignTypeMeta(Iconsax.cake_copy, const Color(0xFFE84393));
    case 'winback':
      return CampaignTypeMeta(Iconsax.refresh_circle_copy, const Color(0xFFFDA544));
    case 'event':
      return CampaignTypeMeta(Iconsax.calendar_copy, const Color(0xFF00CEC9));
    default:
      return CampaignTypeMeta(Iconsax.flash_copy, AppColors.primary);
  }
}

IconData getChannelIcon(String channel) {
  switch (channel) {
    case 'push':
      return Iconsax.notification_copy;
    case 'sms':
      return Iconsax.sms_copy;
    case 'whatsapp':
      return Iconsax.message_copy;
    case 'email':
      return Iconsax.direct_inbox_copy;
    default:
      return Iconsax.send_copy;
  }
}

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onDelete;
  final bool isDeleting;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onDelete,
    this.isDeleting = false,
  });

  Color _statusColor() {
    if (campaign.paused) return const Color(0xFFFDA544);
    switch (campaign.status) {
      case 'ended':
        return const Color(0xFF8B92A6);
      case 'active':
        return const Color(0xFF00B894);
      case 'scheduled':
        return const Color(0xFF0984E3);
      default:
        return const Color(0xFF00B894);
    }
  }

  String _statusLabel() {
    if (campaign.paused) return 'campaign_status_paused';
    switch (campaign.status) {
      case 'ended':
        return 'campaign_status_ended';
      case 'active':
        return 'campaign_status_active';
      case 'scheduled':
        return 'campaign_status_scheduled';
      default:
        return campaign.status;
    }
  }

  Widget _statPill(BuildContext context, IconData icon, String label, String value, Color accent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
        ),
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.015),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 12, color: accent),
          ),
          const SizedBox(width: 6),
          AppText(value, fontSize: 12.5, fontWeight: FontWeight.w800),
          const SizedBox(width: 3),
          AppText(
            label,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _channelBadge(BuildContext context, String channel, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 6),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.16),
              AppColors.primary.withOpacity(0.06),
            ],
          ),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
            width: 1.5,
          ),
        ),
        child: Icon(getChannelIcon(channel), size: 13, color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = getCampaignTypeMeta(campaign.type);
    final statusColor = _statusColor();
    final dateFmt = DateFormat('dd MMM');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.35) : meta.color.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.045),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent bar
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [meta.color, meta.color.withOpacity(0.35)],
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    meta.color.withOpacity(0.20),
                                    meta.color.withOpacity(0.07),
                                  ],
                                ),
                              ),
                              child: Icon(meta.icon, color: meta.color, size: 21),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    campaign.name,
                                    fontSize: isSmall ? 14.5 : 15.5,
                                    fontWeight: FontWeight.w800,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Iconsax.shapes,
                                        size: 11,
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.45),
                                      ),
                                      const SizedBox(width: 4),
                                      AppText(
                                        'campaign_type_${campaign.type}',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.55),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 5),
                                  AppText(
                                    _statusLabel(),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (campaign.description.isNotEmpty) ...[
                          const SizedBox(height: 11),
                          AppText(
                            campaign.description,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Stats
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _statPill(context, Iconsax.people_copy, 'campaign_stat_participants'.tr,
                                '${campaign.participantsCount}', const Color(0xFF6C5CE7)),
                            _statPill(context, Iconsax.tick_circle_copy, 'campaign_stat_delivered'.tr,
                                '${campaign.deliveredCount}', const Color(0xFF00B894)),
                            _statPill(context, Iconsax.send_copy, 'campaign_stat_sent'.tr,
                                '${campaign.sendCount}', const Color(0xFF0984E3)),
                            if (campaign.emailOpens > 0)
                              _statPill(context, Iconsax.eye_copy, 'campaign_stat_opens'.tr,
                                  '${campaign.emailOpens}', const Color(0xFF00CEC9)),
                            if (campaign.failedCount > 0)
                              _statPill(context, Iconsax.warning_2_copy, 'campaign_stat_failed'.tr,
                                  '${campaign.failedCount}', const Color(0xFFD63031)),
                          ],
                        ),

                        const SizedBox(height: 14),
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.07),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Footer
                        Row(
                          children: [
                            Row(
                              children: campaign.channels
                                  .asMap()
                                  .entries
                                  .map((e) => _channelBadge(context, e.value, e.key))
                                  .toList(),
                            ),
                            const SizedBox(width: 10),
                            if (campaign.startDate != null && campaign.endDate != null)
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.calendar_copy,
                                      size: 12,
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.45),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: AppText(
                                        '${dateFmt.format(campaign.startDate!)} - ${dateFmt.format(campaign.endDate!)}',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const Spacer(),
                            const SizedBox(width: 8),
                            _DeleteButton(isDeleting: isDeleting, onTap: onDelete),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  final bool isDeleting;
  final VoidCallback onTap;
  const _DeleteButton({required this.isDeleting, required this.onTap});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade400;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.isDeleting ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              red.withOpacity(_pressed ? 0.22 : 0.13),
              red.withOpacity(_pressed ? 0.14 : 0.05),
            ],
          ),
          border: Border.all(color: red.withOpacity(0.18)),
        ),
        alignment: Alignment.center,
        child: widget.isDeleting
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: red),
              )
            : Icon(Iconsax.trash_copy, size: 15, color: red),
      ),
    );
  }
}