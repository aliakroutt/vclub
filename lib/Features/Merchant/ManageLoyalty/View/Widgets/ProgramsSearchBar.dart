import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/MerchantProgramsController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/ManageLoyalty.dart';


class NewProgramSearchBar extends StatefulWidget {
  const NewProgramSearchBar({super.key});

  @override
  State<NewProgramSearchBar> createState() => _NewProgramSearchBarState();
}

class _NewProgramSearchBarState extends State<NewProgramSearchBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  void _openSearch() {
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    setState(() => _isSearching = false);
    _searchController.clear();
    MerchantProgramsController.to.onSearchChanged("");
    _searchFocusNode.unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = size.height * 0.062;
    const collapsedSearchWidth = 52.0;
    final gap = size.width * 0.03;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        final searchWidth = _isSearching ? fullWidth : collapsedSearchWidth;
        final buttonWidth =
            _isSearching ? 0.0 : (fullWidth - collapsedSearchWidth - gap);

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              // ── NEW PROGRAM BUTTON ──────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                left: 0,
                top: 0,
                bottom: 0,
                width: buttonWidth,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isSearching ? 0 : 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ElevatedButton(
                      onPressed: _isSearching
                          ? null
                          : () => AppNavigator.to(ManageLoyalty()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ).copyWith(
                        elevation: WidgetStateProperty.resolveWith(
                          (states) =>
                              states.contains(WidgetState.pressed) ? 0 : 4,
                        ),
                        shadowColor: WidgetStateProperty.all(
                          AppColors.primary.withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.add_copy,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: size.width * 0.025),
                          AppText(
                            "new_program".tr,
                            fontSize: size.width * 0.038,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── SEARCH ICON / BAR ────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
                right: 0,
                top: 0,
                bottom: 0,
                width: searchWidth,
                child: GestureDetector(
                  onTap: _isSearching ? null : _openSearch,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isSearching
                          ? (isDark
                              ? Colors.white.withOpacity(.06)
                              : Colors.black.withOpacity(.035))
                          : AppColors.primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isSearching
                            ? (isDark
                                ? Colors.white.withOpacity(.10)
                                : Colors.black.withOpacity(.08))
                            : AppColors.primary.withOpacity(.22),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: _isSearching
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        SizedBox(width: _isSearching ? 14 : 0),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            _isSearching
                                ? Iconsax.search_normal_1_copy
                                : Iconsax.search_normal_copy,
                            key: ValueKey(_isSearching),
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        if (_isSearching) ...[
                          SizedBox(width: size.width * .02),
                          Expanded(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 320),
                              opacity: _isSearching ? 1 : 0,
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: (v) => MerchantProgramsController
                                    .to
                                    .onSearchChanged(v),
                                style: TextStyle(
                                  fontSize: size.width * .034,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: "search_program_merchant".tr,
                                  hintStyle: TextStyle(
                                    fontSize: size.width * .034,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white.withOpacity(.35)
                                        : Colors.black.withOpacity(.35),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _closeSearch,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                Iconsax.close_circle,
                                size: 20,
                                color: AppColors.primary.withOpacity(.7),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}