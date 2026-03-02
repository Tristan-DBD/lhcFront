import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/user_role.dart';

class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({required this.role, super.key});

  @override
  Widget build(BuildContext context) {
    final userRole = UserRole.fromString(role);
    final colors = AppColors.current;

    Color badgeColor;
    if (userRole.isCoach) {
      badgeColor = colors.coach;
    } else if (userRole.isAdmin) {
      badgeColor = colors.admin;
    } else if (userRole.isAthleteFull) {
      badgeColor = colors.athleteFull;
    } else if (userRole.isAthleteProg) {
      badgeColor = colors.athleteProg;
    } else if (userRole.isAthleteCo) {
      badgeColor = colors.athleteCo;
    } else {
      badgeColor = colors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        userRole.label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
