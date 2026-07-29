import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:vclub/Features/Merchant/Employee/Models/EmployesModel.dart';

class EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  String get initials =>
      "${employee.firstName.isNotEmpty ? employee.firstName[0] : ''}"
      "${employee.lastName.isNotEmpty ? employee.lastName[0] : ''}"
          .toUpperCase();

  String get joinedAt => DateFormat('dd MMM yyyy').format(employee.createdAt);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double cardPadding = w * 0.042;
    final double avatarSize = w * 0.118;
    final double nameSize = w * 0.038;
    final double subSize = w * 0.030;
    final double badgeSize = w * 0.028;

    final borderColor =
        isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.06);
    final subtitleColor =
        isDark ? Colors.white.withOpacity(0.40) : const Color(0xFF9CA3AF);
    final dividerColor =
        isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05);

    List<Widget> buildActions(BuildContext ctx) => [
      Expanded(
        child: _SlideBtn(
          icon: Iconsax.edit_2,
          label: "edit".tr,
          color: AppColors.primary,
          onTap: onEdit,
        ),
      ),
      Expanded(
        child: _SlideBtn(
          icon: Iconsax.trash,
          label: "delete".tr,
          color: const Color(0xFFEF4444),
          onTap: onDelete,
        ),
      ),
    ];

    ActionPane buildPane(List<Widget> children) => ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.44,
          openThreshold: 0.2,
          children: children,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(employee.id),
        endActionPane: buildPane(buildActions(context)),
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.10),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: avatarSize * 0.38,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(width: w * 0.034),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${employee.firstName} ${employee.lastName}",
                            style: TextStyle(
                              fontSize: nameSize,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: employee.isActive
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              employee.isActive ? "active".tr : "inactive".tr,
                              style: TextStyle(
                                fontSize: badgeSize,
                                fontWeight: FontWeight.w600,
                                color: employee.isActive
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: w * 0.010),
                    Text(
                      employee.email,
                      style: TextStyle(fontSize: subSize, color: subtitleColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: w * 0.022),
                    Container(height: 1, color: dividerColor),
                    SizedBox(height: w * 0.022),
                    Row(
                      children: [
                        Icon(Iconsax.calendar_1, size: subSize, color: subtitleColor),
                        SizedBox(width: w * 0.012),
                        Flexible(
                          child: Text(
                            joinedAt,
                            style: TextStyle(fontSize: subSize, color: subtitleColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            employee.role,
                            style: TextStyle(
                              fontSize: subSize - 1,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SlideBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Slidable.of(context)?.close();
        onTap();
      },
      child: Container(
        margin: Get.locale?.languageCode == 'ar'
            ? const EdgeInsets.only(right: 6, top: 4, bottom: 4)
            : const EdgeInsets.only(left: 6, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: w * 0.052),
            SizedBox(height: w * 0.010),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: w * 0.028,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}