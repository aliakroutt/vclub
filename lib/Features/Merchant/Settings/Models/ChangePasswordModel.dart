class ChangePasswordResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode;

  ChangePasswordResult.success() : success = true, errorMessage = null, errorCode = null;

  ChangePasswordResult.failure(this.errorMessage, {this.errorCode}) : success = false;
}