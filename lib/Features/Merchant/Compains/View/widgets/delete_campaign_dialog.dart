import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

enum _DeleteState { confirm, loading, success, error }

class DeleteCampaignDialog extends StatefulWidget {
  final String name;
  final Future<void> Function() onConfirm;

  const DeleteCampaignDialog({
    super.key,
    required this.name,
    required this.onConfirm,
  });

  @override
  State<DeleteCampaignDialog> createState() => _DeleteCampaignDialogState();
}

class _DeleteCampaignDialogState extends State<DeleteCampaignDialog> {
  _DeleteState _state = _DeleteState.confirm;
  String _error = '';

  Future<void> _handleDelete() async {
    setState(() => _state = _DeleteState.loading);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      setState(() => _state = _DeleteState.success);
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) Get.back(result: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _state = _DeleteState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _state != _DeleteState.loading,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween(begin: 0.94, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  ),
                  child: child,
                ),
              ),
              child: _buildContent(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    switch (_state) {
      case _DeleteState.confirm:
        return _ConfirmView(
          key: const ValueKey('confirm'),
          name: widget.name,
          isDark: isDark,
          onCancel: () => Get.back(result: false),
          onDelete: _handleDelete,
        );
      case _DeleteState.loading:
        return _LoadingView(key: const ValueKey('loading'), isDark: isDark);
      case _DeleteState.success:
        return _SuccessView(key: const ValueKey('success'), isDark: isDark);
      case _DeleteState.error:
        return _ErrorView(
          key: const ValueKey('error'),
          isDark: isDark,
          message: _error,
          onRetry: _handleDelete,
          onClose: () => Get.back(result: false),
        );
    }
  }
}

// ---------------- Sub-views ----------------

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}

class _ConfirmView extends StatelessWidget {
  final String name;
  final bool isDark;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _ConfirmView({
    super.key,
    required this.name,
    required this.isDark,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _IconBadge(icon: Iconsax.trash, color: Colors.red),
        const SizedBox(height: 18),
        AppText(
          'delete_campaign_title',
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
        const SizedBox(height: 8),
        AppText(
          'delete_campaign_confirm',
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: BorderSide(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: AppText('cancel', fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: AppText(
                  'delete',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  final bool isDark;
  const _LoadingView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: LoadingAnimationWidget.fourRotatingDots(
                color: AppColors.primary,
                size: 42,
              ),
        ),
        const SizedBox(height: 18),
        AppText('deleting_campaign', fontSize: 14.5, fontWeight: FontWeight.w700),
        const SizedBox(height: 4),
        AppText(
          'please_wait',
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final bool isDark;
  const _SuccessView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _IconBadge(icon: Iconsax.tick_circle, color: Colors.green),
        const SizedBox(height: 18),
        AppText('campaign_deleted', fontSize: 16, fontWeight: FontWeight.w800),
        const SizedBox(height: 6),
        AppText(
          'campaign_deleted_desc',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          textAlign: TextAlign.center,
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final bool isDark;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _ErrorView({
    super.key,
    required this.isDark,
    required this.message,
    required this.onRetry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _IconBadge(icon: Iconsax.close_circle, color: Colors.red),
        const SizedBox(height: 18),
        AppText('delete_failed', fontSize: 16, fontWeight: FontWeight.w800),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onClose,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: BorderSide(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: AppText('close', fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: AppText(
                  'retry',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}