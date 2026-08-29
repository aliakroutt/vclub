class GoogleWalletResult {
  final String saveUrl;

  GoogleWalletResult({required this.saveUrl});

  factory GoogleWalletResult.fromJson(Map<String, dynamic> json) {
    return GoogleWalletResult(
      saveUrl: json['saveUrl']?.toString() ?? '',
    );
  }
}