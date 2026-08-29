// lib/API/Socket/Models/MembershipJoinedEvent.dart
class MembershipJoinedEvent {
  final String clientId;
  final String clientName;
  final String membershipId;
  final String programId;
  final String? programName;
  final DateTime? joinedAt;

  MembershipJoinedEvent({
    required this.clientId,
    required this.clientName,
    required this.membershipId,
    required this.programId,
    this.programName,
    this.joinedAt,
  });

  factory MembershipJoinedEvent.fromJson(Map<String, dynamic> json) {
    return MembershipJoinedEvent(
      clientId: json['clientId']?.toString() ?? '',
      clientName: json['clientName']?.toString() ?? '',
      membershipId: json['membershipId']?.toString() ?? '',
      programId: json['programId']?.toString() ?? '',
      programName: json['programName']?.toString(),
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'].toString())
          : null,
    );
  }
}