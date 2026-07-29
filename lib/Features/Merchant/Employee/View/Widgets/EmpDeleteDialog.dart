import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Employee/Controllers/EmployeeController.dart';

class EmployeeDeleteDialog extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const EmployeeDeleteDialog({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  static Future<void> show({
    required String employeeId,
    required String employeeName,
  }) {
    return Get.dialog(
      EmployeeDeleteDialog(employeeId: employeeId, employeeName: employeeName),
    );
  }

  @override
  State<EmployeeDeleteDialog> createState() => _EmployeeDeleteDialogState();
}

class _EmployeeDeleteDialogState extends State<EmployeeDeleteDialog> {
  bool _isDeleting = false;
  late final EmployeeController _controller = Get.find<EmployeeController>();

  Future<void> _confirmDelete() async {
    setState(() => _isDeleting = true);

    final success = await _controller.deleteEmployee(widget.employeeId);
    if (!mounted) return;

    if (success) {
      Get.back(); // close dialog only when delete actually succeeded
    } else {
      // controller already fired the error snackbar via ApiErrorHandler
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_isDeleting, // block back/barrier dismiss while deleting
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.trash, color: Color(0xFFEF4444), size: 26),
              ),
              const SizedBox(height: 16),
              AppText(
                'delete_employee_title'.tr,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              AppText(
                'delete_employee_confirm'.trParams({'name': widget.employeeName}),
                fontSize: 13,
                textAlign: TextAlign.center,
                color: isDark
                    ? Colors.white.withOpacity(0.55)
                    : Colors.black.withOpacity(0.55),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isDeleting ? null : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: AppText('cancel'.tr, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDeleting ? null : _confirmDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : AppText('delete'.tr, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}