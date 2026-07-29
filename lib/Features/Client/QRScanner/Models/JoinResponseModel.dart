class JoinProgramResponseModel {
  final bool joined;
  final String? membershipId;
  final String? companyId;
  final String? programId;
  final int points;
  final int stamps;
  final String? tier;

  /// Present when the API returns an explicit error/info message
  /// (e.g. joined == false, or a validation error body).
  final String? message;

  JoinProgramResponseModel({
    required this.joined,
    this.membershipId,
    this.companyId,
    this.programId,
    this.points = 0,
    this.stamps = 0,
    this.tier,
    this.message,
  });

  factory JoinProgramResponseModel.fromJson(Map<String, dynamic> json) {
    int _asInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return JoinProgramResponseModel(
      joined: json['joined'] == true,
      membershipId: json['membershipId']?.toString(),
      companyId: json['companyId']?.toString(),
      programId: json['programId']?.toString(),
      points: _asInt(json['points']),
      stamps: _asInt(json['stamps']),
      tier: json['tier']?.toString(),
      message: json['message']?.toString() ?? json['error']?.toString(),
    );
  }
}