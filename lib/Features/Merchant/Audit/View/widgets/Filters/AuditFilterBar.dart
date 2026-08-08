import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Audit/Controllers/MerchantAuditController.dart';
import 'AuditDateRangeSheet.dart';

class AuditFilterBar extends StatefulWidget {
  const AuditFilterBar({super.key});

  @override
  State<AuditFilterBar> createState() => _AuditFilterBarState();
}

class _AuditFilterBarState extends State<AuditFilterBar> {
  bool _isSearching = false;
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<MerchantAuditController>();
    _searchController = TextEditingController(text: controller.actionQuery.value);
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch({bool clear = false}) {
    final controller = Get.find<MerchantAuditController>();
    if (clear) {
      _searchController.clear();
      controller.onActionSearchChanged("");
    }
    setState(() => _isSearching = false);
    _searchFocusNode.unfocus();
  }

  void _submitSearch() {
    final controller = Get.find<MerchantAuditController>();
    controller.onActionSearchChanged(_searchController.text);
    setState(() => _isSearching = false);
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
    final controller = Get.find<MerchantAuditController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final hasFilters = controller.activeFilterCount > 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween<double>(begin: .96, end: 1).animate(anim),
                  child: child,
                ),
              ),
              child: _isSearching
                  ? _buildExpandedSearch(isDark)
                  : _buildCollapsedRow(context, isDark, controller),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topLeft,
            child: (hasFilters && !_isSearching)
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _ClearFiltersButton(count: controller.activeFilterCount, onTap: controller.clearAllFilters),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    });
  }

  // ── COLLAPSED: search trigger + date button ──
  Widget _buildCollapsedRow(BuildContext context, bool isDark, MerchantAuditController controller) {
    final hasQuery = controller.actionQuery.value.isNotEmpty;
    final hasDate = controller.fromDate.value != null || controller.toDate.value != null;

    return Row(
      key: const ValueKey('collapsed'),
      children: [
        // ── search trigger, takes remaining width ──
        Expanded(
          child: Material(
            color: hasQuery
                ? AppColors.primary.withOpacity(.1)
                : (isDark ? Colors.white.withOpacity(.05) : Colors.white),
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: _openSearch,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: hasQuery
                        ? AppColors.primary.withOpacity(.3)
                        : (isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.search_normal_1_copy, size: 15, color: hasQuery ? AppColors.primary : Colors.grey.withOpacity(.6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        hasQuery ? controller.actionQuery.value : "filter_action".tr,
                        fontSize: 12.5,
                        fontWeight: hasQuery ? FontWeight.w700 : FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        color: hasQuery
                            ? AppColors.primary
                            : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),

        // ── date filter, compact square button ──
        Material(
          color: hasDate
              ? AppColors.primary.withOpacity(.1)
              : (isDark ? Colors.white.withOpacity(.05) : Colors.white),
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: () => showAuditDateRangeSheet(context),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: hasDate
                      ? AppColors.primary.withOpacity(.3)
                      : (isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06)),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(Iconsax.calendar_1, size: 18, color: hasDate ? AppColors.primary : Colors.grey.withOpacity(.6)),
            ),
          ),
        ),
      ],
    );
  }

  // ── EXPANDED: full-width inline search field ──
  Widget _buildExpandedSearch(bool isDark) {
    return Container(
      key: const ValueKey('expanded'),
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.035),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.primary.withOpacity(.3)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 13),
          Icon(Iconsax.search_normal_1_copy, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: "action_placeholder".tr,
                hintStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.withOpacity(.5)),
              ),
              onSubmitted: (_) => _submitSearch(),
            ),
          ),
          GestureDetector(
            onTap: _submitSearch,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Iconsax.tick_circle, size: 20, color: AppColors.primary),
            ),
          ),
          GestureDetector(
            onTap: () => _closeSearch(clear: _searchController.text.isEmpty),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Iconsax.close_circle, size: 19, color: AppColors.primary.withOpacity(.7)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearFiltersButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _ClearFiltersButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.redAccent.withOpacity(.09),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.close_circle, size: 14, color: Colors.redAccent),
              const SizedBox(width: 6),
              AppText("${"clear_filters".tr} ($count)", fontSize: 12, fontWeight: FontWeight.w700, color: Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }
}