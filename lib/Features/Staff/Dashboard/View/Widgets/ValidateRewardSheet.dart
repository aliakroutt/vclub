import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/QRScanner/QrSCanner.dart';
import 'package:vclub/Features/Merchant/QRScanner/Services/ScanApiServices.dart';
import 'package:vclub/Features/Staff/Dashboard/Controllers/StaffValidateRewardController.dart';
import 'package:vclub/Features/Staff/Dashboard/View/Widgets/RewardResultDialog.dart';

Future<void> showValidateRewardSheet(BuildContext context) {
  if (!Get.isRegistered<StaffValidateRewardController>()) {
    Get.put(StaffValidateRewardController());
  }

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return const _ValidateRewardSheetContent();
    },
  );
}

class _ValidateRewardSheetContent extends StatefulWidget {
  const _ValidateRewardSheetContent();

  @override
  State<_ValidateRewardSheetContent> createState() =>
      _ValidateRewardSheetContentState();
}

class _ValidateRewardSheetContentState
    extends State<_ValidateRewardSheetContent> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  bool _showCodeField = false;

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _openCodeField() {
    setState(() => _showCodeField = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _codeFocusNode.requestFocus();
    });
  }

  void _closeCodeField() {
    setState(() => _showCodeField = false);
    _codeController.clear();
    _codeFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StaffValidateRewardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(.15)
                        : Colors.black.withOpacity(.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFB930), Color(0xFFFFCB61)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB930).withOpacity(.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.gift,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          "agent_validate_reward_sheet_title".tr,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                        ),
                        const SizedBox(height: 3),
                        AppText(
                          "agent_validate_reward_sheet_subtitle".tr,
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: .96, end: 1).animate(anim),
                    child: child,
                  ),
                ),
                child: _showCodeField
                    ? _buildCodeEntry(context, controller, isDark)
                    : _buildOptionsRow(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── OPTIONS: Scan QR / Enter code ──
  Widget _buildOptionsRow(BuildContext context) {
    return Row(
      key: const ValueKey('options'),
      children: [
        Expanded(
          child: _OptionTile(
            icon: Iconsax.scan,
            label: "agent_scan_qr_code".tr,
            color: AppColors.primary,
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const QrScannerMerchant(isRedeem: true));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OptionTile(
            icon: Iconsax.ticket_star,
            label: "agent_enter_code_manually".tr,
            color: const Color(0xFFFFB930),
            onTap: _openCodeField,
          ),
        ),
      ],
    );
  }

  // ── CODE ENTRY FIELD + VALIDATE BUTTON ──
  Widget _buildCodeEntry(BuildContext context, StaffValidateRewardController controller, bool isDark) {
  return Column(
    key: const ValueKey('code_entry'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(
        "agent_reward_code_label".tr,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
      ),
      const SizedBox(height: 8),
      Container(
        height: 54,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.035),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(.1) : Colors.black.withOpacity(.08),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Iconsax.ticket_discount, size: 19, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: "agent_enter_reward_code".tr,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white.withOpacity(.35) : Colors.black.withOpacity(.35),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _closeCodeField,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Iconsax.close_circle, size: 19, color: AppColors.primary.withOpacity(.6)),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Obx(() {
        final loading = controller.isValidating.value;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: loading ? null : () => _handleValidate(context, controller),
              child: Center(
                child: loading
                    ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 24)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.tick_circle, size: 17, color: Colors.white),
                          const SizedBox(width: 8),
                          AppText("agent_validate_reward_action".tr, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ],
                      ),
              ),
            ),
          ),
        );
      }),
    ],
  );
}

Future<void> _handleValidate(BuildContext context, StaffValidateRewardController controller) async {
  final code = _codeController.text.trim();

  if (code.isEmpty) {
    AppSnackBar.error("agent_reward_code_required".tr);
    return;
  }

  try {
    final result = await controller.validateByCode(code);

    if (!context.mounted) return;

    // Close the sheet first, then show the result dialog on top of Home.
    Navigator.pop(context);

    await showRewardResultDialog(
      context,
      success: true,
    );
  } on ApiException catch (e) {
    if (!context.mounted) return;

    await showRewardResultDialog(
      context,
      success: false,
      message: e.message, // real backend error message
    );
  } catch (e) {
    if (!context.mounted) return;

    await showRewardResultDialog(
      context,
      success: false,
    );
  }
}
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: color.withOpacity(.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(.22)),
          ),
          child: Column(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(.75)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 12),
              AppText(
                label,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
