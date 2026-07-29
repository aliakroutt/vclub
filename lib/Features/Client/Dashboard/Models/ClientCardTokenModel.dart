class ClientCardQrModel {
  final String qrToken;
  final int expiresIn;

  ClientCardQrModel({
    required this.qrToken,
    required this.expiresIn,
  });

  factory ClientCardQrModel.fromJson(Map<String, dynamic> json) {
    return ClientCardQrModel(
      qrToken: json['qrToken'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qrToken': qrToken,
      'expiresIn': expiresIn,
    };
  }
}