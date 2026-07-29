import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class ClientsEmptyState extends StatelessWidget {
  final bool isSearching;
  const ClientsEmptyState({super.key, this.isSearching = false});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          Icon(Iconsax.people_copy, size: 48, color: muted),
          const SizedBox(height: 16),
          AppText(
            isSearching ? 'no_clients_found' : 'no_clients_yet',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          AppText(
            isSearching ? 'no_clients_found_subtitle' : 'no_clients_yet_subtitle',
            fontSize: 13,
            color: muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}