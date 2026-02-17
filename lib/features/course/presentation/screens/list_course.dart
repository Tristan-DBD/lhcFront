import 'package:flutter/material.dart';
import 'package:lhc_front/features/course/presentation/screens/add_course.dart';
import 'package:lhc_front/services/user.dart';
import '../../../../../constant/app_colors.dart';
import '../../../../../services/course.dart';
import '../../../../../widgets/role_badge.dart';

class ListCoursePage extends StatefulWidget {
  const ListCoursePage({super.key});

  @override
  State<ListCoursePage> createState() => _ListCoursePageState();
}

class _ListCoursePageState extends State<ListCoursePage> {
  List<Map<String, dynamic>> courses = [];
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  // Méthode pour rafraîchir la liste des cours
  void refreshCourses() {
    _loadCourses();
  }

  // Méthode pour supprimer un cours
  Future<void> _deleteCourse(int courseId) async {
    try {
      final response = await CourseService.delete(courseId);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cours supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        // Rafraîchir la liste après suppression
        refreshCourses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la suppression: ${response['message'] ?? 'Erreur inconnue'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Méthode pour formater la date et heure
  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      // Convertir en heure locale (GMT+1 pour la France)
      final localDateTime = dateTime.toLocal();

      final date =
          '${localDateTime.day.toString().padLeft(2, '0')}/${localDateTime.month.toString().padLeft(2, '0')}/${localDateTime.year}';
      final time =
          '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
      return '$date à $time';
    } catch (e) {
      return dateTimeString;
    }
  }

  Future<void> _loadCourses() async {
    try {
      final response = await CourseService.getAll();
      if (response['success'] == false) {
        setState(() {
          isLoading = false;
          errorMessage = response['message'] ?? 'Erreur lors du chargement';
        });
        return;
      }

      List<Map<String, dynamic>> courseList;
      if (response['data'] is List && response['data'].isNotEmpty) {
        courseList = List<Map<String, dynamic>>.from(
          response['data'][0]['message'],
        );
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Format de réponse invalide';
        });
        return;
      }
      setState(() {
        // Trier les cours par date de début (du plus proche au plus lointain)
        courseList.sort((a, b) {
          if (a['startAt'] == null && b['startAt'] == null) return 0;
          if (a['startAt'] == null) return 1;
          if (b['startAt'] == null) return -1;

          try {
            final dateA = DateTime.parse(a['startAt']);
            final dateB = DateTime.parse(b['startAt']);
            return dateA.compareTo(dateB);
          } catch (e) {
            return 0;
          }
        });

        courses = courseList;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Cours collectifs',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.secondary,
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
                    onCourseCreated: () {
                      // Rafraîchir la liste des cours quand un cours est créé
                      refreshCourses();
                    },
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
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (courses.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage ?? 'Aucun cours trouvé',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Créez votre premier cours en appuyant sur le bouton +',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    ...courses.map(
                      (course) => FutureBuilder<Widget>(
                        future: _ExpansionTileBuilder(course),
                        builder: (constext, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Erreur de chargement');
                          }
                          return snapshot.data ?? const SizedBox.shrink();
                        },
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

  Future<Widget> _ExpansionTileBuilder(course) async {
    final registration = await CourseService.getNbrRegistration(course['id']);

    if (registration['success'] == false) {
      return const Text('Erreur lors du chargement');
    }

    final nbrRegistration = registration['data'][0]['message'].length;

    return Dismissible(
      key: Key(course['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        // Supprimer le cours
        _deleteCourse(course['id']);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: BorderSide.none,
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      course['description'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    if (course['startAt'] != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              _formatDateTime(course['startAt']),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getParticipantColor(
                nbrRegistration,
                course['maxParticipants'],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$nbrRegistration/${course['maxParticipants']}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
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
                              color: AppColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Participants ($nbrRegistration)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$nbrRegistration/${course['maxParticipants']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ...(await _buildParticipantCards(registration['data'])),
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
    List<Widget> widgets = [];

    for (var registrationItem in registrations) {
      // Les données sont imbriquées dans 'message'
      final messageList = registrationItem['message'];
      if (messageList == null || messageList.isEmpty) {
        continue;
      }

      // Parcourir TOUS les utilisateurs inscrits dans messageList
      for (var registration in messageList) {
        final userId = registration['userId'];

        // Convertir en int si nécessaire
        int? userIdInt;
        if (userId is int) {
          userIdInt = userId;
        } else if (userId is String) {
          userIdInt = int.tryParse(userId);
        }

        if (userIdInt == null) {
          widgets.add(
            Container(
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person_outline, color: Colors.grey[600]),
                ),
                title: Text('Utilisateur non identifié'),
                subtitle: Text('ID non disponible'),
              ),
            ),
          );
          continue;
        }

        // Récupérer les infos de l'utilisateur
        try {
          final userResponse = await UserService.getUserById(userIdInt);

          if (userResponse['success'] == true && userResponse['data'] != null) {
            // Les données sont imbriquées dans data[0]['message']
            final userData = userResponse['data'][0]['message'];

            widgets.add(
              Container(
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      (userData['name'] ?? '?')[0].toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    '${userData['name'] ?? 'Nom non défini'} ${userData['surname'] ?? ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    userData['email'] ?? 'Email non disponible',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  trailing: RoleBadge(role: userData['role'] ?? ''),
                ),
              ),
            );
          } else {
            widgets.add(
              Container(
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withValues(alpha: 0.2),
                    child: Icon(Icons.error_outline, color: Colors.red[700]),
                  ),
                  title: Text('Utilisateur non trouvé'),
                  subtitle: Text('ID: $userId'),
                ),
              ),
            );
          }
        } catch (e) {
          widgets.add(
            Container(
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  child: Icon(Icons.warning, color: Colors.orange[700]),
                ),
                title: Text('Erreur de chargement'),
                subtitle: Text('Veuillez réessayer'),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  Color _getParticipantColor(int current, int max) {
    double ratio = current / max;
    if (ratio >= 1.0) {
      return Colors.red; // Plein
    } else if (ratio >= 0.8) {
      return Colors.orange; // Presque plein
    } else if (ratio >= 0.5) {
      return AppColors.primary; // Moitié plein
    } else {
      return Colors.green; // Beaucoup de places
    }
  }
}
