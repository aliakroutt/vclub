import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class TopClientsCard extends StatelessWidget {
  const TopClientsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final clients = [
      {
        "name": "Ali Akrout",
        "email": "ali@email.com",
        "points": 12450,
      },
      {
        "name": "Sara Ben Ali",
        "email": "sara@email.com",
        "points": 9800,
      },
      {
        "name": "Omar Trabelsi",
        "email": "omar@email.com",
        "points": 7650,
      },
    ];

    return Container(
      padding: EdgeInsets.all(size.width * 0.045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                width: size.width * 0.11,
                height: size.width * 0.11,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.primary.withOpacity(0.12),
                ),
                child: const Icon(
                  Iconsax.people,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(width: size.width * 0.03),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "top_clients",
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.w800,
                    ),
                    SizedBox(height: 2),
                    AppText(
                      "by_accumulated_points",
                      fontSize: size.width * 0.032,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.02),

          /// LIST (MAX 3)
          ...clients.take(3).map((c) {
            final name = c["name"].toString();
            final email = c["email"].toString();
            final points = c["points"] as int;

            final initials = _getInitials(name);

            return Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.015),
              child: _ClientTile(
                name: name,
                email: email,
                points: points,
                initials: initials,
                size: size,
                isDark: isDark,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(" ");
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return "${parts[0][0]}${parts[1][0]}".toUpperCase();
  }
}

/// ================= CLIENT TILE =================

class _ClientTile extends StatelessWidget {
  final String name;
  final String email;
  final int points;
  final String initials;
  final Size size;
  final bool isDark;

  const _ClientTile({
    required this.name,
    required this.email,
    required this.points,
    required this.initials,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.03),
      ),
      child: Row(
        children: [
          /// AVATAR (INITIALS)
          Container(
            width: size.width * 0.12,
            height: size.width * 0.12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:  LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.2),
                ],
              ),
            ),
            child: Center(
              child: AppText(
                initials,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          SizedBox(width: size.width * 0.03),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  name,
                  fontSize: size.width * 0.038,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: 2),
                AppText(
                  email,
                  fontSize: size.width * 0.031,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          /// POINTS
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.height * 0.008,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xFFFFC542).withOpacity(0.15),
            ),
            child: AppText(
              "$points pts",
              fontSize: size.width * 0.032,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFB300),
            ),
          ),
        ],
      ),
    );
  }
}