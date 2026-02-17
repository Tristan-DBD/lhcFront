import 'package:flutter/material.dart';
import '../../../../constant/app_colors.dart';

class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String displayText = role;

    switch (role) {
      case 'COACH':
        badgeColor = AppColors.coach;
        break;
      case 'ATHLETE_FULL':
        badgeColor = AppColors.athleteFull;
        break;
      case 'ATHLETE_PROG':
        badgeColor = AppColors.athleteProg;
        break;
      case 'ATHLETE_CO':
        badgeColor = AppColors.athleteCo;
        break;
      default:
        badgeColor = AppColors.black;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
