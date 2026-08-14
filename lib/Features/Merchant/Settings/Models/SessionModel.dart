class SessionModel {
  final String jti;
  final String? ipAddress;
  final String? browser;
  final String? os;
  final DateTime createdAt;
  final DateTime expiresAt;

  SessionModel({
    required this.jti,
    this.ipAddress,
    this.browser,
    this.os,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isKnownDevice => browser != null || os != null;

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      jti: json['jti']?.toString() ?? '',
      ipAddress: json['ipAddress']?.toString(),
      browser: json['browser']?.toString(),
      os: json['os']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}