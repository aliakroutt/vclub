import 'package:vclub/Features/Merchant/FortuneWheel/Models/WheelSegmentDto.dart';

class UpdateWheelConfigDto {
  final bool active;
  final List<WheelSegmentDto> segments;
  final List<String> triggers; // purchase, google_review, inscription, event
  final int maxPerDay;
  final int maxPerWeek;
  final bool activeHoursEnabled;
  final String? activeHoursStart;
  final String? activeHoursEnd;

  UpdateWheelConfigDto({
    required this.active,
    required this.segments,
    required this.triggers,
    required this.maxPerDay,
    required this.maxPerWeek,
    required this.activeHoursEnabled,
    this.activeHoursStart,
    this.activeHoursEnd,
  });

  Map<String, dynamic> toJson() => {
        "active": active,
        "segments": segments.map((s) => s.toJson()).toList(),
        "triggers": triggers,
        "maxPerDay": maxPerDay,
        "maxPerWeek": maxPerWeek,
        "activeHoursEnabled": activeHoursEnabled,
        if (activeHoursEnabled) "activeHoursStart": activeHoursStart,
        if (activeHoursEnabled) "activeHoursEnd": activeHoursEnd,
      };
}