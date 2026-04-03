import 'package:flutter/material.dart';
import '../../data/models/coaching_slot.dart';
import '../controllers/coaching_slot_controller.dart';

class CoachingSlotListTile extends StatelessWidget {
  final CoachingSlot slot;
  final CoachingSlotController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onBook;
  final VoidCallback onCancel;

  const CoachingSlotListTile({
    required this.slot,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
    required this.onBook,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBooked = !slot.isAvailable();
    final bool isUserBooked = slot.isBookedByUser(controller.userId);
    final bool canManage =
        controller.userRole == 'ADMIN' || controller.userRole == 'COACH';
    final bool isProcessing = controller.processingSlotId == slot.id;

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
        title: _buildTitle(context, isBooked),
        trailing: _buildTrailing(isBooked, context),
        children: [_buildDetails(context, canManage, isUserBooked, isBooked, isProcessing)],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isBooked) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isBooked
                ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: isBooked
                  ? Theme.of(context).colorScheme.error.withValues(alpha: 0.2)
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.1),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isBooked ? Icons.event_busy : Icons.event_available,
            color: isBooked
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Créneau avec ${slot.coachId != '0' ? 'Coach #${slot.coachId}' : 'Coach'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimeRange(slot.startTime, slot.endTime),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing(bool isBooked, BuildContext context) {
    if (isBooked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Réservé',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Disponible',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    bool canManage,
    bool isUserBooked,
    bool isBooked,
    bool isProcessing,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            Icons.access_time,
            'Durée',
            _formatDuration(slot.startTime, slot.endTime),
          ),
          const SizedBox(height: 12),
          if (slot.bookings.isNotEmpty) ...[
            _buildInfoRow(
              context,
              Icons.person,
              'Réservé par',
              slot.bookings.first.user?.fullName ?? 'Utilisateur',
            ),
            const SizedBox(height: 12),
          ],
          if (canManage || !isUserBooked || isUserBooked || !isBooked) ...[
            _buildActions(context, canManage, isUserBooked, isBooked, isProcessing),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    bool canManage,
    bool isUserBooked,
    bool isBooked,
    bool isProcessing,
  ) {
    return Row(
      children: [
        if (canManage) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Modifier'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Supprimer'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
        if (!canManage && (!isBooked || isUserBooked)) ...[
          if (!isUserBooked)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : onBook,
                icon: isProcessing 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.person_add, size: 18),
                label: const Text('S\'inscrire'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          if (isUserBooked)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isProcessing ? null : onCancel,
                icon: isProcessing 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.person_remove, size: 18),
                label: const Text('Se désinscrire'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
        ],
      ],
    );
  }

  String _formatTimeRange(DateTime startTime, DateTime endTime) {
    final start =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  String _formatDuration(DateTime startTime, DateTime endTime) {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}min';
  }
}
