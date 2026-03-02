import 'package:flutter/material.dart';
import 'package:lhc_front/features/course/presentation/controllers/course_controller.dart';
import 'add_course.dart';
import 'edit_course.dart';
import '../../../user/data/services/user_service.dart';
import '../../../user/data/models/user.dart';
import '../../data/models/course.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/services/course_service.dart';
import '../../../../core/widgets/role_badge.dart';

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

  Future<void> _handleDelete(int courseId) async {
    final success = await _controller.deleteCourse(courseId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Cours supprimé avec succès'
              : 'Erreur lors de la suppression',
        ),
        backgroundColor: success
            ? AppColors.current.success
            : AppColors.current.error,
      ),
    );
  }

  Future<void> _handleRegister(int courseId) async {
    final success = await _controller.registerToCourse(courseId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Inscription au cours réussie'
              : 'Erreur lors de l\'inscription',
        ),
        backgroundColor: success
            ? AppColors.current.success
            : AppColors.current.error,
      ),
    );
  }

  Future<void> _handleUnregister(int courseId) async {
    final success = await _controller.unregisterFromCourse(courseId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Désinscription du cours réussie'
              : 'Erreur lors de la désinscription',
        ),
        backgroundColor: success
            ? AppColors.current.success
            : AppColors.current.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
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
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCourseScreen(
                        onCourseCreated: () => _controller.loadCourses(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                if (_controller.isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.current.primary,
                      ),
                    ),
                  )
                else if (_controller.courses.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 64,
                            color: AppColors.current.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _controller.errorMessage ?? 'Aucun cours trouvé',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.current.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Créez votre premier cours en appuyant sur le bouton +',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.current.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _controller.courses.length,
                      itemBuilder: (context, index) {
                        final course = _controller.courses[index];
                        return _buildCourseCard(course);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseCard(Course course) {
    return FutureBuilder<Widget>(
      future: _ExpansionTileBuilder(course),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data ?? const SizedBox.shrink();
      },
    );
  }

  Future<Widget> _ExpansionTileBuilder(Course course) async {
    final registration = await CourseService.getNbrRegistration(course.id);

    if (!registration.success) {
      return const Text('Erreur lors du chargement');
    }

    final nbrRegistration = registration.data![0]['message'].length;

    return Dismissible(
      key: Key(course.id.toString()),
      background:
          _controller.userRole == 'ADMIN' || _controller.userRole == 'COACH'
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.current.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: AppColors.current.white, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    'Modifier',
                    style: TextStyle(
                      color: AppColors.current.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.current.success,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.how_to_reg,
                    color: AppColors.current.white,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Register',
                    style: TextStyle(
                      color: AppColors.current.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.current.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: AppColors.current.white, size: 28),
            const SizedBox(height: 4),
            Text(
              _controller.userRole == 'ADMIN' || _controller.userRole == 'COACH'
                  ? 'Supprimer'
                  : 'Unregister',
              style: TextStyle(
                color: AppColors.current.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (_controller.userRole == 'ADMIN' ||
              _controller.userRole == 'COACH') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditCourseScreen(
                  course: course,
                  onCourseUpdated: () => _controller.loadCourses(),
                ),
              ),
            );
          } else {
            _handleRegister(course.id);
          }
        } else {
          if (_controller.userRole == 'ADMIN' ||
              _controller.userRole == 'COACH') {
            _handleDelete(course.id);
          } else {
            _handleUnregister(course.id);
          }
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.current.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.current.shadow.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          backgroundColor: AppColors.current.transparent,
          collapsedBackgroundColor: AppColors.current.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.current.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: AppColors.current.primary,
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
                        color: AppColors.current.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.description ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.current.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.current.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppColors.current.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _controller.formatDateTime(course.startAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.current.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getParticipantColor(
                nbrRegistration,
                course.maxParticipants,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$nbrRegistration/${course.maxParticipants}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.current.white,
              ),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.current.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.current.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.current.shadow.withValues(
                            alpha: 0.05,
                          ),
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
                              color: AppColors.current.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Participants ($nbrRegistration)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.current.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.current.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$nbrRegistration/${course.maxParticipants}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.current.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<List<Widget>>(
                          future: _buildParticipantCards(registration.data!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Column(children: snapshot.data ?? []);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Widget>> _buildParticipantCards(
    List<dynamic> registrations,
  ) async {
    final List<Widget> widgets = [];

    for (var registrationItem in registrations) {
      final messageList = registrationItem['message'];
      if (messageList == null || messageList.isEmpty) continue;

      for (var registration in messageList) {
        final userId = registration['userId'];
        int? userIdInt;
        if (userId is int) {
          userIdInt = userId;
        } else if (userId is String) {
          userIdInt = int.tryParse(userId);
        }

        if (userIdInt == null) {
          widgets.add(_errorUserCard('Utilisateur non identifié'));
          continue;
        }

        try {
          final userResponse = await UserService.getUserById(userIdInt);
          if (userResponse.success && userResponse.data != null) {
            final user = userResponse.data!;
            widgets.add(_userCard(user));
          } else {
            widgets.add(_errorUserCard('Utilisateur non trouvé ($userIdInt)'));
          }
        } catch (e) {
          widgets.add(_errorUserCard('Erreur de chargement'));
        }
      }
    }
    return widgets;
  }

  Widget _userCard(User user) {
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

  Widget _errorUserCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.current.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.current.error.withValues(alpha: 0.2),
          child: Icon(Icons.error_outline, color: AppColors.current.error),
        ),
        title: Text(message),
      ),
    );
  }

  Color _getParticipantColor(int current, int max) {
    final double ratio = max > 0 ? current / max : 0;
    if (ratio >= 1.0) return AppColors.current.error;
    if (ratio >= 0.8) return AppColors.current.orange;
    if (ratio >= 0.5) return AppColors.current.primary;
    return AppColors.grey;
  }
}
