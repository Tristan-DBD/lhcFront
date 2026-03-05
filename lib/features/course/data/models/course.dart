import '../../../user/data/models/user.dart';

class CourseRegistration {
  final int id;
  final int userId;
  final int courseId;
  final User? user;
  final DateTime createdAt;

  CourseRegistration({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.createdAt,
    this.user,
  });

  factory CourseRegistration.fromJson(Map<String, dynamic> json) {
    return CourseRegistration(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      courseId: json['courseId'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class Course {
  final int id;
  final String title;
  final String? description;
  final int durationMinutes;
  final int maxParticipants;
  final DateTime startAt;
  final int coachId;
  final List<CourseRegistration> registrations;

  Course({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.maxParticipants,
    required this.startAt,
    required this.coachId,
    this.description,
    this.registrations = const [],
  });

  int get registrationCount => registrations.length;

  factory Course.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? registrationJson = json['registrations'];
    final registrations = registrationJson != null
        ? registrationJson.map((r) => CourseRegistration.fromJson(r)).toList()
        : <CourseRegistration>[];

    return Course(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      maxParticipants: json['maxParticipants'] as int? ?? 0,
      startAt: json['startAt'] != null
          ? DateTime.parse(json['startAt'] as String)
          : DateTime.now(),
      coachId: json['coachId'] as int? ?? 0,
      registrations: registrations,
    );
  }

  bool isUserRegistered(int? userId) {
    if (userId == null) return false;
    return registrations.any((r) => r.userId == userId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'maxParticipants': maxParticipants,
      'startAt': startAt.toIso8601String(),
      'coachId': coachId,
    };
  }

  @override
  String toString() {
    return 'Course(id: $id, title: $title, registrations: ${registrations.length})';
  }
}
