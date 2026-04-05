import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/course_controller.dart';
import '../widgets/course_list_tile.dart';
import 'add_course.dart';
import 'edit_course.dart';
import '../../data/models/course.dart';
import '../../../../core/utils/message_service.dart';

class ListCoursePage extends StatefulWidget {
  const ListCoursePage({super.key});

  @override
  State<ListCoursePage> createState() => _ListCoursePageState();
}

class _ListCoursePageState extends State<ListCoursePage>
    with SingleTickerProviderStateMixin {
  late final CourseController _controller;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = CourseController();
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

  Future<void> _handleDelete(String courseId) async {
    final success = await _controller.deleteCourse(courseId);
    _showSnackBar(
      success ? 'Cours supprimé avec succès' : 'Erreur lors de la suppression',
      success,
    );
  }

  Future<void> _handleRegister(String courseId) async {
    final success = await _controller.registerToCourse(courseId);
    _showSnackBar(
      success
          ? 'Inscription au cours réussie'
          : 'Erreur lors de l\'inscription',
      success,
    );
  }

  Future<void> _handleUnregister(String courseId) async {
    final success = await _controller.unregisterFromCourse(courseId);
    _showSnackBar(
      success
          ? 'Désinscription du cours réussie'
          : 'Erreur lors de la désinscription',
      success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final dailyCourses = _controller.getCoursesForDay(
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
                      : dailyCourses.isEmpty
                      ? _buildEmptyState()
                      : _buildCourseList(dailyCourses),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendar() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TableCalendar<Course>(
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
        eventLoader: (day) => _controller.getCoursesForDay(day),
        onDaySelected: (selectedDay, focusedDay) {
          _controller.selectedDay = selectedDay;
          _controller.focusedDay = focusedDay;
        },
        onPageChanged: (focusedDay) {
          _controller.focusedDay = focusedDay;
          _controller.loadCourses();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Cours collectifs',
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
                builder: (context) => AddCourseScreen(
                  onCourseCreated: () => _controller.loadCourses(),
                ),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
      ],
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
              'Aucun cours programmé',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Il n\'y a pas encore de sessions pour cette date. Revenez plus tard ou contactez votre coach.',
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

  Widget _buildCourseList(List<Course> dailyCourses) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: dailyCourses.length,
      itemBuilder: (context, index) {
        final course = dailyCourses[index];
        return CourseListTile(
          course: course,
          controller: _controller,
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCourseScreen(
                course: course,
                onCourseUpdated: () => _controller.loadCourses(),
              ),
            ),
          ),
          onDelete: () => _handleDelete(course.id),
          onRegister: () => _handleRegister(course.id),
          onUnregister: () => _handleUnregister(course.id),
        );
      },
    );
  }
}
