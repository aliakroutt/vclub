import 'dart:async';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vclub/Features/Client/Rewards/Models/ClientReviewRewardModel.dart';
import 'package:vclub/Features/Client/Rewards/Services/RewardsClientService.dart';

enum WriteReviewStage { idle, starting, waiting, claiming, done }

class WriteReviewController extends GetxController {
  final Rx<WriteReviewStage> stage = WriteReviewStage.idle.obs;
  final RxInt secondsLeft = 0.obs;

  Timer? _timer;
  String? _reviewToken;

  bool get isBusy => stage.value != WriteReviewStage.idle && stage.value != WriteReviewStage.done;

  /// Full flow for one company's "write a review" action:
  /// 1. Call /start — button shows a loader.
  /// 2. On response, open the review link externally and start a
  ///    countdown for minDwellSeconds — button shows the timer.
  /// 3. When the countdown ends, call /claim — button shows a loader again.
  /// 4. On response, report the result via [onResult] so the caller can
  ///    show a dialog and refresh data.
  Future<void> writeReview({
    required String companyId,
    required String reviewLink,
    required void Function(ReviewClaimModel? result, String? errorMessage) onResult,
  }) async {
    if (isBusy) return;

    try {
      stage.value = WriteReviewStage.starting;

      final startResult = await GoogleReviewApiClient.startReview(companyId);
      _reviewToken = startResult.reviewToken;

      if (reviewLink.isEmpty) {
        stage.value = WriteReviewStage.idle;
        onResult(null, "review_link_missing".tr);
        return;
      }

      final launched = await launchUrlString(reviewLink, mode: LaunchMode.externalApplication);
      if (!launched) {
        stage.value = WriteReviewStage.idle;
        onResult(null, "review_link_open_failed".tr);
        return;
      }

      // 2. Start the countdown — button shows the timer while the user is
      //    presumably on the review page.
      stage.value = WriteReviewStage.waiting;
      secondsLeft.value = startResult.minDwellSeconds;

      final completer = Completer<void>();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (secondsLeft.value <= 1) {
          timer.cancel();
          secondsLeft.value = 0;
          completer.complete();
        } else {
          secondsLeft.value--;
        }
      });

      await completer.future;

      // 3. Countdown finished — claim the reward.
      stage.value = WriteReviewStage.claiming;

      final claimResult = await GoogleReviewApiClient.claimReview(companyId, _reviewToken!);

      stage.value = WriteReviewStage.done;
      onResult(claimResult, null);
    } catch (e) {
      stage.value = WriteReviewStage.idle;
      onResult(null, "review_claim_failed".tr);
    } finally {
      _timer?.cancel();
      // Reset to idle shortly after done, so the button returns to its
      // normal state for a potential retry (e.g. another company's card).
      Future.delayed(const Duration(milliseconds: 300), () {
        if (stage.value == WriteReviewStage.done) {
          stage.value = WriteReviewStage.idle;
        }
      });
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}