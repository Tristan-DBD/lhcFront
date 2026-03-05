import 'package:flutter/material.dart';
import '../../data/models/course.dart';
import '../controllers/course_controller.dart';
import 'participant_card.dart';

class CourseListTile extends StatelessWidget {
  final Course course;
  final CourseController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRegister;
  final VoidCallback onUnregister;

  const CourseListTile({
    required this.course,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
    required this.onRegister,
    required this.onUnregister,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFull = course.registrationCount >= course.maxParticipants;
    final bool isUserRegistered = course.isUserRegistered(controller.userId);
    final bool canManage =
        controller.userRole == 'ADMIN' || controller.userRole == 'COACH';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        title: _buildTitle(context),
        trailing: _buildTrailing(isFull, context),
        children: [_buildDetails(context, canManage, isUserRegistered, isFull)],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.fitness_center,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (course.description != null && course.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    course.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),
              _buildTimeBadge(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            controller.formatDateTime(course.startAt),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(bool isFull, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getParticipantColor(
          course.registrationCount,
          course.maxParticipants,
          context,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${course.registrationCount}/${course.maxParticipants}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    bool canManage,
    bool isRegistered,
    bool isFull,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!canManage) _buildActionButtons(context, isRegistered, isFull),
          const SizedBox(height: 16),
          _buildParticipantSection(context, canManage),
          if (canManage) ...[
            const SizedBox(height: 16),
            _buildAdminActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    bool isRegistered,
    bool isFull,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isRegistered ? onUnregister : (isFull ? null : onRegister),
        style: ElevatedButton.styleFrom(
          backgroundColor: isRegistered
              ? Theme.of(context).colorScheme.error
              : Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isRegistered
              ? 'Se désinscrire'
              : (isFull ? 'Complet' : 'S\'inscrire'),
        ),
      ),
    );
  }

  Widget _buildParticipantSection(BuildContext context, bool canManage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Participants (${course.registrationCount})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (course.registrations.isEmpty)
            const Text('Aucun participant pour le moment.')
          else
            ...course.registrations
                .map((reg) => ParticipantCard(user: reg.user!))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Modifier'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Supprimer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getParticipantColor(int current, int max, BuildContext context) {
    final double ratio = max > 0 ? current / max : 0;
    if (ratio >= 1.0) return Theme.of(context).colorScheme.error;
    if (ratio >= 0.8) return Colors.orange;
    if (ratio >= 0.5) return Theme.of(context).colorScheme.primary;
    return Colors.grey;
  }
}
