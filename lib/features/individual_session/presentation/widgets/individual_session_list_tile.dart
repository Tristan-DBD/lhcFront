import 'package:flutter/material.dart';
import '../../data/models/individual_session.dart';
import '../../../../core/widgets/app_button.dart';

class IndividualSessionListTile extends StatelessWidget {
  final IndividualSession session;
  final String? userId;
  final String? userRole;
  final bool isProcessing;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onBook;
  final VoidCallback? onCancel;

  const IndividualSessionListTile({
    required this.session,
    this.userId,
    this.userRole,
    this.isProcessing = false,
    this.onEdit,
    this.onDelete,
    this.onBook,
    this.onCancel,
    super.key,
  });

  bool get _isCoachOrAdmin =>
      userRole == 'COACH' || userRole == 'ADMIN';

  @override
  Widget build(BuildContext context) {
    final isTaken = session.registrations.isNotEmpty;
    final isBookedByMe = session.isUserRegistered(userId);
    final bookedByUser = session.registrations.isNotEmpty
        ? session.registrations.first.user
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ExpansionTile(
        leading: Icon(
          isTaken ? Icons.person : Icons.person_outline,
          color: isTaken
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          '${_formatTimeRange(session.startAt, session.durationMinutes)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          session.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isTaken
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            isTaken ? 'Réservé' : 'Disponible',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isTaken
                  ? Theme.of(context).colorScheme.onError
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (session.description != null &&
                    session.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(session.description!),
                  ),
                Text(
                  'Durée: ${_formatDuration(session.durationMinutes)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (bookedByUser != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Réservé par: ${bookedByUser.surname} ${bookedByUser.name}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                if (_isCoachOrAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: isProcessing ? null : onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Modifier'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: isProcessing ? null : onDelete,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Supprimer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isBookedByMe)
                          AppButton(
                            text: 'Se désinscrire',
                            isLoading: isProcessing,
                            onPressed: onCancel,
                          )
                        else if (!isTaken)
                          AppButton(
                            text: "S'inscrire",
                            isLoading: isProcessing,
                            onPressed: onBook,
                          )
                        else
                          Text(
                            'Réservé par ${bookedByUser?.surname ?? "quelqu\'un"}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeRange(DateTime startAt, int durationMinutes) {
    final startLocal = startAt.toLocal();
    final endLocal = startLocal.add(Duration(minutes: durationMinutes));
    final startStr =
        '${startLocal.hour.toString().padLeft(2, '0')}:${startLocal.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${endLocal.hour.toString().padLeft(2, '0')}:${endLocal.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    return '${m}min';
  }
}
