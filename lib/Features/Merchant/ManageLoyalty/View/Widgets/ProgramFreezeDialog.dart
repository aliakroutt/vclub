import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/MerchantProgramsController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramsModel.dart';

enum _DialogStage { confirm, loading, error }

class ProgramFreezeDialog extends StatefulWidget {
  const ProgramFreezeDialog({super.key, required this.program});

  final ProgramModel program;

  static Future<void> show(BuildContext context, ProgramModel program) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ProgramFreezeDialog(program: program),
    );
  }

  @override
  State<ProgramFreezeDialog> createState() => _ProgramFreezeDialogState();
}

class _ProgramFreezeDialogState extends State<ProgramFreezeDialog> {
  _DialogStage _stage = _DialogStage.confirm;
  String _errorMsg = '';

  bool get _isFreezing => widget.program.active; // active now -> action is "freeze"

  Future<void> _confirm() async {
    setState(() => _stage = _DialogStage.loading);
    try {
      await MerchantProgramsController.to.toggleProgramStatus(widget.program);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      AppSnackBar.success(
        _isFreezing ? 'program_frozen_success'.tr : 'program_unfrozen_success'.tr,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = _extractError(e);
        _stage = _DialogStage.error;
      });
    }
  }

  String _extractError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'] ?? data['error'];
        if (msg != null) return msg.toString();
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    return _isFreezing ? 'freeze_program_failed'.tr : 'unfreeze_program_failed'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final accent = _isFreezing ? const Color(0xFFFF9F43) : const Color(0xFF00C896);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? .45 : .12),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (_stage) {
              _DialogStage.confirm => _buildConfirm(isDark, accent, key: const ValueKey('c')),
              _DialogStage.loading => _buildLoading(accent, key: const ValueKey('l')),
              _DialogStage.error => _buildError(isDark, key: const ValueKey('e')),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConfirm(bool isDark, Color accent, {required Key key}) {
    final title = _isFreezing ? 'freeze_program_title'.tr : 'unfreeze_program_title'.tr;
    final message = (_isFreezing ? 'freeze_program_message'.tr : 'unfreeze_program_message'.tr)
        .replaceAll('{name}', widget.program.name);

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withOpacity(.12)),
          child: Icon(_isFreezing ? Iconsax.lock : Iconsax.unlock, color: accent, size: 28),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: isDark ? Colors.white.withOpacity(.60) : Colors.black.withOpacity(.55),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _DialogButton(
                label: 'cancel'.tr,
                onTap: () => Navigator.of(context).pop(false),
                filled: false,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DialogButton(
                label: _isFreezing ? 'freeze_confirm'.tr : 'unfreeze_confirm'.tr,
                onTap: _confirm,
                filled: true,
                color: accent,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoading(Color accent, {required Key key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: LoadingAnimationWidget.fourRotatingDots(
                color: accent,
                size: 30,
              ),
        ),
        const SizedBox(height: 20),
        Text(
          _isFreezing ? 'freezing_in_progress'.tr : 'unfreezing_in_progress'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildError(bool isDark, {required Key key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent.withOpacity(.12)),
          child: const Icon(Iconsax.warning_2, color: Colors.redAccent, size: 28),
        ),
        const SizedBox(height: 18),
        Text(
          'action_failed'.tr,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMsg,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: isDark ? Colors.white.withOpacity(.60) : Colors.black.withOpacity(.55),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _DialogButton(
                label: 'close'.tr,
                onTap: () => Navigator.of(context).pop(false),
                filled: false,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DialogButton(
                label: 'retry_merchant'.tr,
                onTap: () => setState(() => _stage = _DialogStage.confirm),
                filled: true,
                color: Colors.redAccent,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onTap,
    required this.filled,
    required this.isDark,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool isDark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? c : (isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: filled ? Colors.white : (isDark ? Colors.white.withOpacity(.85) : Colors.black87),
          ),
        ),
      ),
    );
  }
}