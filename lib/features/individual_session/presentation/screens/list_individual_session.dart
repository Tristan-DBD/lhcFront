import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/individual_session_controller.dart';
import '../widgets/individual_session_list_tile.dart';
import 'add_individual_session.dart';
import 'edit_individual_session.dart';
import '../../data/models/individual_session.dart';
import '../../../../core/utils/message_service.dart';

class ListIndividualSessionPage extends StatefulWidget {
  const ListIndividualSessionPage({super.key});

  @override
  State<ListIndividualSessionPage> createState() =>
      _ListIndividualSessionPageState();
}

class _ListIndividualSessionPageState extends State<ListIndividualSessionPage>
    with SingleTickerProviderStateMixin {
  late final IndividualSessionController _controller;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = IndividualSessionController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, bool success) {
    if (!mounted) return;
    if (success) {
      MessageService.showSuccess(context, message);
    } else {
      MessageService.showError(context, message);
    }
  }

  Future<void> _handleDelete(String sessionId) async {
    final success = await _controller.deleteSession(sessionId);
    _showSnackBar(
      success ? 'Séance supprimée' : 'Erreur lors de la suppression',
      success,
    );
  }

  Future<void> _handleBook(String sessionId) async {
    if (_controller.userId == null) return;
    final success = await _controller.registerToSession(sessionId);
    _showSnackBar(
      success ? 'Inscription réussie' : "Erreur lors de l'inscription",
      success,
    );
  }

  Future<void> _handleCancel(String sessionId) async {
    if (_controller.userId == null) return;
    final success = await _controller.unregisterFromSession(sessionId);
    _showSnackBar(
      success ? 'Désinscription réussie' : 'Erreur lors de la désinscription',
      success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final dailySessions = _controller.getSessionsForDay(
          _controller.selectedDay,
        );

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: Column(
              children: [
                _buildCalendar(),
                const Divider(height: 1),
                Expanded(
                  child: _controller.isLoading
                      ? _buildSkeletonList()
                      : dailySessions.isEmpty
                          ? _buildEmptyState()
                          : _buildSessionList(dailySessions),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Séances individuelles',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      actions: [
        if (_controller.userRole == 'ADMIN' || _controller.userRole == 'COACH')
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddIndividualSessionScreen(
                  onSessionCreated: () => _controller.loadSessions(),
                ),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TableCalendar<IndividualSession>(
        locale: 'fr_FR',
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _controller.focusedDay,
        calendarFormat: CalendarFormat.week,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(_controller.selectedDay, day),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Theme.of(context).colorScheme.primary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          defaultTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          weekendTextStyle: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          markerDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.bold,
          ),
          weekendStyle: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
        eventLoader: (day) => _controller.getSessionsForDay(day),
        onDaySelected: (selectedDay, focusedDay) {
          _controller.selectedDay = selectedDay;
          _controller.focusedDay = focusedDay;
        },
        onPageChanged: (focusedDay) {
          _controller.focusedDay = focusedDay;
          _controller.loadSessions();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Aucune séance programmée',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Il n\'y a pas encore de séances individuelles pour cette date.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonItem(),
    );
  }

  Widget _buildSkeletonItem() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 0.6).animate(_pulseController),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 10,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList(List<IndividualSession> dailySessions) {
    return RefreshIndicator(
      onRefresh: () => _controller.loadSessions(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: dailySessions.length,
        itemBuilder: (context, index) {
          final session = dailySessions[index];
          return IndividualSessionListTile(
            session: session,
            userId: _controller.userId,
            userRole: _controller.userRole,
            isProcessing: false,
            onEdit: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditIndividualSessionScreen(
                    session: session,
                    onSessionUpdated: () => _controller.loadSessions(),
                  ),
                ),
              );
            },
            onDelete: () => _handleDelete(session.id),
            onBook: () => _handleBook(session.id),
            onCancel: () => _handleCancel(session.id),
          );
        },
      ),
    );
  }
}
