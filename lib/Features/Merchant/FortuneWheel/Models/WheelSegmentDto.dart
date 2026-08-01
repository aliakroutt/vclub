class WheelSegmentDto {
  final String label;
  final String type; // gift, discount, points, cashback, no_win
  final String value;
  final num probability;
  final String color;
  final int maxWinnersPerDay;

  WheelSegmentDto({
    required this.label,
    required this.type,
    required this.value,
    required this.probability,
    required this.color,
    required this.maxWinnersPerDay,
  });

  Map<String, dynamic> toJson() => {
        "label": label,
        "type": type,
        "value": value,
        "probability": probability,
        "color": color,
        "maxWinnersPerDay": maxWinnersPerDay,
      };
}