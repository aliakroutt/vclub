import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/Clients/Controllers/MerchantClientsController.dart';
import 'package:vclub/Features/Merchant/Clients/Models/ClientModel.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/MerchantProgramsController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramsModel.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Models/SendNotificationDto.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Services/MerchantNotificationsComposeApiClient.dart';

class ComposeNotificationController extends GetxController {
  static const int titleMax = 80;
  static const int bodyMax = 300;

  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final FocusNode titleFocus = FocusNode();
  final FocusNode bodyFocus = FocusNode();

  final RxInt titleLength = 0.obs;
  final RxInt bodyLength = 0.obs;

  final Rx<NotificationRecipientType> recipientType =
      NotificationRecipientType.all.obs;

  final Rx<ProgramModel?> selectedProgram = Rx<ProgramModel?>(null);
  final Rx<ClientModel?> selectedClient = Rx<ClientModel?>(null);

  final RxBool sending = false.obs;

  final RxString titleError = "".obs;
  final RxString bodyError = "".obs;
  final RxString recipientError = "".obs;

  @override
  void onInit() {
    super.onInit();

    titleController.addListener(() {
      titleLength.value = titleController.text.length;
      if (titleError.value.isNotEmpty) _validateTitle();
    });

    bodyController.addListener(() {
      bodyLength.value = bodyController.text.length;
      if (bodyError.value.isNotEmpty) _validateBody();
    });
  }

  // =========================
  // LAZY DEPENDENCIES
  // =========================
  void ensureProgramsLoaded() {
    final controller = Get.isRegistered<MerchantProgramsController>()
        ? Get.find<MerchantProgramsController>()
        : Get.put(MerchantProgramsController());

    if (!controller.initialLoaded.value && !controller.loading.value) {
      controller.fetchPrograms(refresh: true);
    }
  }

  void ensureClientsLoaded() {
    if (!Get.isRegistered<ClientsController>()) {
      Get.put(ClientsController());
    }
  }

  // =========================
  // RECIPIENT SELECTION
  // =========================
  void selectRecipient(NotificationRecipientType type) {
    if (recipientType.value == type) return;

    recipientType.value = type;
    recipientError.value = "";

    if (type == NotificationRecipientType.program) ensureProgramsLoaded();
    if (type == NotificationRecipientType.client) ensureClientsLoaded();

    if (type != NotificationRecipientType.program) selectedProgram.value = null;
    if (type != NotificationRecipientType.client) selectedClient.value = null;
  }

  void selectProgram(ProgramModel program) {
    selectedProgram.value = program;
    recipientError.value = "";
  }

  void selectClient(ClientModel client) {
    selectedClient.value = client;
    recipientError.value = "";
  }

  // =========================
  // TEXT FORMATTING
  // =========================
  void wrapSelection(String marker) {
    final text = bodyController.text;
    final selection = bodyController.selection;

    if (!selection.isValid || selection.isCollapsed) {
      final cursor = selection.start >= 0 ? selection.start : text.length;
      final newText = text.replaceRange(cursor, cursor, "$marker$marker");

      bodyController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursor + marker.length),
      );
      return;
    }

    final start = selection.start;
    final end = selection.end;
    final selected = text.substring(start, end);
    final newText = text.replaceRange(start, end, "$marker$selected$marker");

    bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: start,
        extentOffset: end + marker.length * 2,
      ),
    );
  }

  void insertEmoji(String emoji) {
    final text = bodyController.text;
    final selection = bodyController.selection;
    final cursor = selection.start >= 0 ? selection.start : text.length;

    if (text.length + emoji.length > bodyMax) return;

    final newText = text.replaceRange(cursor, cursor, emoji);

    bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor + emoji.length),
    );
  }

  // =========================
  // VALIDATION
  // =========================
  bool _validateTitle() {
    final value = titleController.text.trim();

    if (value.isEmpty) {
      titleError.value = "title_required".tr;
      return false;
    }
    if (value.length < 3) {
      titleError.value = "title_too_short".tr;
      return false;
    }
    if (value.length > titleMax) {
      titleError.value = "title_too_long".tr;
      return false;
    }

    titleError.value = "";
    return true;
  }

  bool _validateBody() {
    final value = bodyController.text.trim();

    if (value.isEmpty) {
      bodyError.value = "message_required".tr;
      return false;
    }
    if (value.length > bodyMax) {
      bodyError.value = "message_too_long".tr;
      return false;
    }

    bodyError.value = "";
    return true;
  }

  bool _validateRecipient() {
    if (recipientType.value == NotificationRecipientType.program &&
        selectedProgram.value == null) {
      recipientError.value = "select_program_error".tr;
      return false;
    }
    if (recipientType.value == NotificationRecipientType.client &&
        selectedClient.value == null) {
      recipientError.value = "select_client_error".tr;
      return false;
    }

    recipientError.value = "";
    return true;
  }

  // =========================
  // SUBMIT
  // =========================
  Future<SendNotificationResult> submit() async {
    final validTitle = _validateTitle();
    final validBody = _validateBody();
    final validRecipient = _validateRecipient();

    if (!validTitle || !validBody || !validRecipient) {
      return const SendNotificationResult(success: false, message: null);
    }

    sending.value = true;

    try {
      String segment;
      String? programId;
      String? clientId;

      switch (recipientType.value) {
        case NotificationRecipientType.all:
          segment = "all";
          break;
        case NotificationRecipientType.vip:
          segment = "vip";
          break;
        case NotificationRecipientType.inactive:
          segment = "inactive";
          break;
        case NotificationRecipientType.program:
          segment = "all";
          programId = selectedProgram.value?.id;
          break;
        case NotificationRecipientType.client:
          segment = "all";
          clientId = selectedClient.value!.clientId;
          break;
      }

      final dto = SendNotificationDto(
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
        segment: segment,
        programId: programId,
        clientId: clientId,
      );

      await MerchantNotificationsComposeApiClient.sendNotification(dto);

      return const SendNotificationResult(success: true);
    } catch (e) {
      final msg = MerchantNotificationsComposeApiClient.extractErrorMessage(e);
      return SendNotificationResult(success: false, message: msg);
    } finally {
      sending.value = false;
    }
  }

  void resetForm() {
    titleController.clear();
    bodyController.clear();
    recipientType.value = NotificationRecipientType.all;
    selectedProgram.value = null;
    selectedClient.value = null;
    titleError.value = "";
    bodyError.value = "";
    recipientError.value = "";
  }

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    titleFocus.dispose();
    bodyFocus.dispose();
    super.onClose();
  }
}