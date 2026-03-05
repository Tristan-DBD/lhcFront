import 'package:flutter/material.dart';
import '../controllers/course_controller.dart';
import '../widgets/course_list_tile.dart';
import 'add_course.dart';
import 'edit_course.dart';

class ListCoursePage extends StatefulWidget {
  const ListCoursePage({super.key});

  @override
  State<ListCoursePage> createState() => _ListCoursePageState();
}

class _ListCoursePageState extends State<ListCoursePage> {
  late final CourseController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CourseController();
  }

  void _showSnackBar(String message, bool success) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success
            ? Colors.green
            : Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _handleDelete(int courseId) async {
    final success = await _controller.deleteCourse(courseId);
    _showSnackBar(
      success ? 'Cours supprimé avec succès' : 'Erreur lors de la suppression',
      success,
    );
  }

  Future<void> _handleRegister(int courseId) async {
    final success = await _controller.registerToCourse(courseId);
    _showSnackBar(
      success
          ? 'Inscription au cours réussie'
          : 'Erreur lors de l\'inscription',
      success,
    );
  }

  Future<void> _handleUnregister(int courseId) async {
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
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: SafeArea(
            child: _controller.courses.isEmpty
                ? _buildEmptyState()
                : _buildCourseList(),
          ),
        );
      },
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            _controller.errorMessage ??
                'Il n\'y a pas de cours de prévu pour l\'instant',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revenez plus tard ou contactez votre coach',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _controller.courses.length,
      itemBuilder: (context, index) {
        final course = _controller.courses[index];
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
