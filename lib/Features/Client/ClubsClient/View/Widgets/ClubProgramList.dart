import 'package:flutter/material.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/MerchantModel.dart';
import 'package:vclub/Features/Client/ClubsClient/View/Clubs.dart' show ClubViewerRole;
import 'ClubProgramCard.dart';

class ClubProgramsList extends StatelessWidget {
  final List<LoyaltyProgram> programs;
  final ClubViewerRole role;

  /// Ids of programs the current client has already joined. Ignored
  /// for non-client roles.
  final Set<String> joinedProgramIds;

  final ValueChanged<LoyaltyProgram> onDetails;
  final ValueChanged<LoyaltyProgram>? onJoin;

  const ClubProgramsList({
    super.key,
    required this.programs,
    required this.role,
    this.joinedProgramIds = const {},
    required this.onDetails,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    if (programs.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        if (!isWide) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: programs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _card(programs[index]),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          itemCount: programs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, index) => _card(programs[index]),
        );
      },
    );
  }

  Widget _card(LoyaltyProgram program) {
    return ClubProgramCard(
      program: program,
      role: role,
      isJoined: joinedProgramIds.contains(program.id),
      onDetails: () => onDetails(program),
      onJoin: onJoin == null ? null : () => onJoin!(program),
    );
  }
}