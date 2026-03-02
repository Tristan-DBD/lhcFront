class Course {
  final int id;
  final String title;
  final String? description;
  final int durationMinutes;
  final int maxParticipants;
  final DateTime startAt;
  final int coachId;

  Course({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.maxParticipants,
    required this.startAt,
    required this.coachId,
    this.description,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      maxParticipants: json['maxParticipants'] as int? ?? 0,
      startAt: DateTime.parse(json['startAt'] as String),
      coachId: json['coachId'] as int? ?? 0,
    );
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
    return 'Course(id: $id, title: $title, startAt: $startAt)';
  }
}
