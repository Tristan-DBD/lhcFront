import '../../../user/data/models/user.dart';

class IndividualSessionRegistration {
  final String id;
  final String userId;
  final String courseId;
  final User? user;
  final DateTime createdAt;

  IndividualSessionRegistration({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.createdAt,
    this.user,
  });

  factory IndividualSessionRegistration.fromJson(Map<String, dynamic> json) {
    return IndividualSessionRegistration(
      id: json['id'] as String? ?? '0',
      userId: json['userId'] as String? ?? '0',
      courseId: json['courseId'] as String? ?? '0',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class IndividualSession {
  final String id;
  final String title;
  final String? description;
  final int durationMinutes;
  final DateTime startAt;
  final String coachId;
  final List<IndividualSessionRegistration> registrations;

  IndividualSession({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.startAt,
    required this.coachId,
    this.description,
    this.registrations = const [],
  });

  int get registrationCount => registrations.length;

  factory IndividualSession.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? registrationJson = json['registrations'];
    final registrations = registrationJson != null
        ? registrationJson
            .map((r) => IndividualSessionRegistration.fromJson(r))
            .toList()
        : <IndividualSessionRegistration>[];

    return IndividualSession(
      id: json['id'] as String? ?? '0',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      startAt: json['startAt'] != null
          ? DateTime.parse(json['startAt'] as String)
          : DateTime.now(),
      coachId: json['coachId'] as String? ?? '0',
      registrations: registrations,
    );
  }

  bool isUserRegistered(String? userId) {
    if (userId == null) return false;
    return registrations.any((r) => r.userId == userId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'startAt': startAt.toIso8601String(),
      'coachId': coachId,
    };
  }

  @override
  String toString() {
    return 'IndividualSession(id: $id, title: $title, registrations: ${registrations.length})';
  }
}
