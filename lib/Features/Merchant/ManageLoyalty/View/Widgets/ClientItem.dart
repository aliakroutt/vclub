import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ClientModel.dart';

class ClientListItem extends StatelessWidget {
  final ClientModel client;
  final VoidCallback? onTap;

  const ClientListItem({
    super.key,
    required this.client,
    this.onTap,
  });

  /// Formats the join date in a clean, readable way.
  /// Expects `client.joinedAt` to be a [DateTime]. If it's still a [String]
  /// in your model, parse it first (e.g. DateTime.parse(client.joinedAt)).
  String _formatJoinedDate() {
  return DateFormat('dd MMM yyyy').format(client.createdAt);
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final levelColors = client.level.gradient;

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * .014),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size.width * .05),
          child: Container(
            padding: EdgeInsets.all(size.width * .036),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(size.width * .05),
              border: Border.all(
                color: AppColors.primary.withOpacity(.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? .18 : .04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar with initials
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: size.width * .134,
                          height: size.width * .134,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: levelColors,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: levelColors.last.withOpacity(.3),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: AppText(
                            client.initials,
                            fontSize: size.width * .036,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            padding: EdgeInsets.all(size.width * .009),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              border: Border.all(
                                color: Theme.of(context).cardColor,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              client.level.icon,
                              size: size.width * .028,
                              color: levelColors.last,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: size.width * .032),

                    // Name / join date / email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            client.fullName,
                            fontSize: size.width * .039,
                            fontWeight: FontWeight.w700,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: size.height * .004),
                          Row(
                            children: [
                              Icon(
                                Iconsax.calendar_1,
                                size: size.width * .03,
                                color: Colors.grey,
                              ),
                              SizedBox(width: size.width * .012),
                              Expanded(
                                child: AppText(
                                  '${'joined_on'.tr} ${_formatJoinedDate()}',
                                  fontSize: size.width * .028,
                                  color: Colors.grey,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * .003),
                          Row(
                            children: [
                              Icon(
                                Iconsax.sms,
                                size: size.width * .03,
                                color: Colors.grey,
                              ),
                              SizedBox(width: size.width * .012),
                              Expanded(
                                child: AppText(
                                  client.email,
                                  fontSize: size.width * .028,
                                  color: Colors.grey,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: size.width * .02),

                    // Badge chip
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * .022,
                        vertical: size.height * .006,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.width * .03),
                        gradient: LinearGradient(
                          colors: [
                            levelColors.first.withOpacity(.14),
                            levelColors.last.withOpacity(.14),
                          ],
                        ),
                        border: Border.all(
                          color: levelColors.last.withOpacity(.25),
                        ),
                      ),
                      child: AppText(
                        client.level.labelKey.tr,
                        fontSize: size.width * .026,
                        fontWeight: FontWeight.w700,
                        color: levelColors.last,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * .016),
                Divider(
                  height: 1,
                  color: AppColors.primary.withOpacity(.06),
                ),
                SizedBox(height: size.height * .014),

                // Stats row
                // replace the stats Row's three _StatChip entries with:
Row(
  children: [
    Expanded(
      child: _StatChip(
        icon: client.primaryStatIcon,
        label: client.primaryStatLabelKey.tr,
        value: '${client.primaryStatValue}',
      ),
    ),
    _VerticalDivider(size: size),
    Expanded(
      child: _StatChip(
        icon: Iconsax.shop,
        label: 'stat_visits'.tr,
        value: '${client.visits}',
      ),
    ),
    _VerticalDivider(size: size),
    Expanded(
      child: _StatChip(
        icon: Iconsax.gift,
        label: 'stat_rewards'.tr,
        value: '${client.rewardsUsed}',
      ),
    ),
  ],
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(size.width * .014),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.08),
            borderRadius: BorderRadius.circular(size.width * .022),
          ),
          child: Icon(
            icon,
            size: size.width * .038,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: size.height * .006),
        AppText(
          value,
          fontSize: size.width * .032,
          fontWeight: FontWeight.w800,
        ),
        SizedBox(height: size.height * .001),
        AppText(
          label,
          fontSize: size.width * .024,
          color: Colors.grey,
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Size size;
  const _VerticalDivider({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * .034,
      width: 1,
      color: AppColors.primary.withOpacity(.08),
      margin: EdgeInsets.symmetric(horizontal: size.width * .012),
    );
  }
}