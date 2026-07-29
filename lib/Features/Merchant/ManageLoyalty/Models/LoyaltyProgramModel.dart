enum ProgramMode { points, stamps, cashback }

class LoyaltyProgramModel {
  final String title;
  final ProgramMode mode;
  final bool isActive;
  final String subtitle;

  const LoyaltyProgramModel({
    required this.title,
    required this.mode,
    required this.isActive,
    required this.subtitle,
  });
}