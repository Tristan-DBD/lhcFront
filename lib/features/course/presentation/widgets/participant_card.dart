import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../user/data/models/user.dart';
import '../../../../core/widgets/role_badge.dart';

class ParticipantCard extends StatelessWidget {
  final User user;

  const ParticipantCard({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.current.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.current.primary.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.current.primary.withValues(alpha: 0.1),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: AppColors.current.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.fullName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.current.textPrimary,
          ),
        ),
        subtitle: Text(
          user.email.isNotEmpty ? user.email : 'Email non disponible',
          style: TextStyle(
            color: AppColors.current.textSecondary,
            fontSize: 14,
          ),
        ),
        trailing: RoleBadge(role: user.role),
      ),
    );
  }
}
