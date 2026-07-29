import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/MerchantModel.dart';
import 'package:vclub/Features/Client/ClubsClient/View/Clubs.dart'
    show ClubViewerRole;
import 'package:vclub/Features/Client/ClubsClient/View/Widgets/ClubProgramList.dart';

/// "Loyalty programs" title + an icon that animates into an inline
/// search field, sitting above [ClubProgramsList]. Filters the
/// programs shown below by name as the user types.
class ClubProgramsSection extends StatefulWidget {
  final List<LoyaltyProgram> programs;
  final ClubViewerRole role;
  final Set<String> joinedProgramIds;
  final ValueChanged<LoyaltyProgram> onDetails;
  final ValueChanged<LoyaltyProgram>? onJoin;

  const ClubProgramsSection({
    super.key,
    required this.programs,
    required this.role,
    this.joinedProgramIds = const {},
    required this.onDetails,
    this.onJoin,
  });

  @override
  State<ClubProgramsSection> createState() => _ClubProgramsSectionState();
}

class _ClubProgramsSectionState extends State<ClubProgramsSection> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<LoyaltyProgram> get _filteredPrograms {
    if (_query.trim().isEmpty) return widget.programs;
    final query = _query.trim().toLowerCase();
    return widget.programs
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      } else {
        _searchController.clear();
        _query = '';
        _searchFocusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
           
            children: [
              
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        axis: Axis.horizontal,
                        axisAlignment: -1,
                        sizeFactor: animation,
                        child: child,
                      ),
                    );
                  },
                  child: _isSearching
                      ? _SearchField(
                          key: const ValueKey('search'),
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          isDark: isDark,
                          onChanged: (value) => setState(() => _query = value),
                        )
                      : Padding(
                          key: const ValueKey('title'),
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Align(
              alignment: Get.locale?.languageCode == 'ar' ? Alignment.centerRight  : Alignment.centerLeft,
              child:  AppText(
                            'club_programs_section_title'.tr,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.primary
                                : AppColors.primaryDark,
                          )),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              _SearchToggleButton(
                isSearching: _isSearching,
                isDark: isDark,
                onTap: _toggleSearch,
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredPrograms.isEmpty
              ? _NoResults(isDark: isDark)
              : ClubProgramsList(
                  programs: _filteredPrograms,
                  role: widget.role,
                  joinedProgramIds: widget.joinedProgramIds,
                  onDetails: widget.onDetails,
                  onJoin: widget.onJoin,
                ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _SearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.10)
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.search_normal_copy,
            size: 17,
            color: isDark
                ? AppColors.primary.withOpacity(0.6)
                : AppColors.primaryLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.primary : AppColors.primaryDark,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'club_programs_section_search_hint'.tr,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.primary.withOpacity(0.4)
                      : AppColors.primaryLight.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchToggleButton extends StatelessWidget {
  final bool isSearching;
  final bool isDark;
  final VoidCallback onTap;

  const _SearchToggleButton({
    required this.isSearching,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Two real states: filled accent tint while searching,
          // neutral surface + soft shadow while idle.
          color: AppColors.primary.withOpacity(isDark ? 0.20 : 0.12),

          boxShadow: isSearching
              ? []
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(.3)
                        : Colors.black.withOpacity(.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => RotationTransition(
            turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(
            isSearching ? Iconsax.close_circle : Iconsax.search_normal_copy,
            key: ValueKey(isSearching),
            size: 18,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final bool isDark;

  const _NoResults({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.search_status,
              size: 30,
              color: isDark
                  ? AppColors.primary.withOpacity(0.35)
                  : AppColors.primaryLight.withOpacity(0.5),
            ),
            const SizedBox(height: 10),
            AppText(
              'club_programs_section_no_results'.tr,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.primary.withOpacity(0.6)
                  : AppColors.primaryLight,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
