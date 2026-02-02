import 'dart:convert';

class TempDataService {
  static const String _usersJson = '''
  [
    {
      "id": 19,
      "name": "Tristan",
      "surname": "Debord",
      "email": "tristan.debord@gmail.com",
      "phone": "0612345678",
      "age": 28,
      "weight": 75,
      "role": "COACH",
      "stat": [
        {
          "id": 7,
          "userId": 19,
          "squat": 100,
          "bench": 100,
          "deadlift": 100
        }
      ],
      "imageUri": "profileImage/default.png",
      "progUri": null
    },
    {
      "id": 20,
      "name": "Jean",
      "surname": "Dupont",
      "email": "jean.dupont@email.com",
      "phone": "0623456789",
      "age": 25,
      "weight": 68,
      "role": "ATHLETE_PROG",
      "stat": [
        {
          "id": 8,
          "userId": 20,
          "squat": 80,
          "bench": 60,
          "deadlift": 90
        }
      ],
      "imageUri": "profileImage/default.png",
      "progUri": null
    },
    {
      "id": 21,
      "name": "Marie",
      "surname": "Martin",
      "email": "marie.martin@email.com",
      "phone": "0634567890",
      "age": 32,
      "weight": 62,
      "role": "COACH",
      "stat": [
        {
          "id": 9,
          "userId": 21,
          "squat": 120,
          "bench": 85,
          "deadlift": 140
        }
      ],
      "imageUri": "profileImage/default.png",
      "progUri": null
    },
    {
      "id": 22,
      "name": "Pierre",
      "surname": "Bernard",
      "email": "pierre.bernard@email.com",
      "phone": "0645678901",
      "age": 29,
      "weight": 80,
      "role": "ATHLETE_CO",
      "stat": [
        {
          "id": 10,
          "userId": 22,
          "squat": 90,
          "bench": 70,
          "deadlift": 110
        }
      ],
      "imageUri": "profileImage/default.png",
      "progUri": null
    },
    {
      "id": 23,
      "name": "Sophie",
      "surname": "Petit",
      "email": "sophie.petit@email.com",
      "phone": "0656789012",
      "age": 26,
      "weight": 58,
      "role": "ATHLETE_FULL",
      "stat": [
        {
          "id": 11,
          "userId": 23,
          "squat": 60,
          "bench": 45,
          "deadlift": 75
        }
      ],
      "imageUri": "profileImage/default.png",
      "progUri": null
    },
    {
      "id": 24,
      "name": "Lucas",
      "surname": "Dubois",
      "email": "lucas.dubois@email.com",
      "phone": "0667890123",
      "age": 31,
      "weight": 85,
      "role": "COACH",
      "stat": [
        {
          "id": 12,
          "userId": 24,
          "squat": 140,
          "bench": 100,
          "deadlift": 160
        }
      ],
      "imageUri": "profileImage/default.png",
      "progUri": null
    },
    {
      "id": 25,
      "name": "Emma",
      "surname": "Leroy",
      "email": "emma.leroy@email.com",
      "phone": "0678901234",
      "age": 24,
      "weight": 55,
      "role": "ATHLETE_PROG",
      "stat": [
        {
          "id": 13,
          "userId": 25,
          "squat": 70,
          "bench": 50,
          "deadlift": 85
        }
      ],
      "imageUri": "profileImage/default.png",
      "progUri": null
    },
    {
      "id": 26,
      "name": "Nicolas",
      "surname": "Moreau",
      "email": "nicolas.moreau@email.com",
      "phone": "0689012345",
      "age": 27,
      "weight": 72,
      "role": "ATHLETE_CO",
      "stat": [
        {
          "id": 14,
          "userId": 26,
          "squat": 85,
          "bench": 65,
          "deadlift": 100
        }
      ],
      "imageUri": "profileImage/default.png",
      "progUri": null
    },
    {
      "id": 27,
      "name": "Camille",
      "surname": "Laurent",
      "email": "camille.laurent@email.com",
      "phone": "0690123456",
      "age": 30,
      "weight": 65,
      "role": "COACH",
      "stat": [
        {
          "id": 15,
          "userId": 27,
          "squat": 110,
          "bench": 80,
          "deadlift": 130
        }
      ],
      "imageUri": "profileImage/default.png",
      "progUri": null
    },
    {
      "id": 28,
      "name": "Antoine",
      "surname": "Simon",
      "email": "antoine.simon@email.com",
      "phone": "0601234567",
      "age": 23,
      "weight": 70,
      "role": "ATHLETE_FULL",
      "stat": [
        {
          "id": 16,
          "userId": 28,
          "squat": 75,
          "bench": 55,
          "deadlift": 90
        }
      ],
      "imageUri": "profileImage/default.png",
      "progUri": null
    },
    {
      "id": 29,
      "name": "Léa",
      "surname": "Garcia",
      "email": "lea.garcia@email.com",
      "phone": "0612345678",
      "age": 22,
      "weight": 52,
      "role": "ATHLETE_PROG",
      "stat": [
        {
          "id": 17,
          "userId": 29,
          "squat": 65,
          "bench": 48,
          "deadlift": 80
        }
      ],
      "imageUri": "profileImage/default.png",
      "progUri": null
    }
  ]
  ''';

  static const String _coursesJson = '''
  [
    {
      "id": 5,
      "title": "Course modifiée coach",
      "description": "Description du cours de test",
      "startAt": "2026-01-15T21:34:40.193Z",
      "durationMinutes": 60,
      "maxParticipants": 10,
      "coachId": 17,
      "createdAt": "2026-01-15T21:34:40.198Z",
      "updatedAt": "2026-01-15T21:34:40.268Z"
    },
    {
      "id": 6,
      "title": "Yoga Matinal",
      "description": "Session de yoga douce pour bien commencer la journée",
      "startAt": "2026-02-20T07:00:00.000Z",
      "durationMinutes": 60,
      "maxParticipants": 15,
      "coachId": 21,
      "createdAt": "2026-01-10T08:00:00.000Z",
      "updatedAt": "2026-01-15T09:30:00.000Z"
    },
    {
      "id": 7,
      "title": "HIIT Intense",
      "description": "Entraînement haute intensité pour brûler les calories",
      "startAt": "2026-02-20T12:30:00.000Z",
      "durationMinutes": 45,
      "maxParticipants": 12,
      "coachId": 24,
      "createdAt": "2026-01-12T10:15:00.000Z",
      "updatedAt": "2026-01-18T14:20:00.000Z"
    },
    {
      "id": 8,
      "title": "Pilates",
      "description": "Renforcement musculaire et gainage",
      "startAt": "2026-02-20T18:00:00.000Z",
      "durationMinutes": 50,
      "maxParticipants": 10,
      "coachId": 27,
      "createdAt": "2026-01-08T16:45:00.000Z",
      "updatedAt": "2026-01-22T11:10:00.000Z"
    },
    {
      "id": 9,
      "title": "Boxing Fitness",
      "description": "Combinaison de boxe et fitness cardio",
      "startAt": "2026-02-20T19:00:00.000Z",
      "durationMinutes": 55,
      "maxParticipants": 20,
      "coachId": 24,
      "createdAt": "2026-01-05T13:30:00.000Z",
      "updatedAt": "2026-01-25T15:45:00.000Z"
    },
    {
      "id": 10,
      "title": "Stretching",
      "description": "Étirements et relaxation musculaire",
      "startAt": "2026-02-20T20:00:00.000Z",
      "durationMinutes": 40,
      "maxParticipants": 25,
      "coachId": 21,
      "createdAt": "2026-01-03T09:20:00.000Z",
      "updatedAt": "2026-01-20T17:30:00.000Z"
    }
  ]
  ''';

  // Récupérer tous les utilisateurs
  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final List<dynamic> jsonList = json.decode(_usersJson);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Récupérer un utilisateur par son ID
  static Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      final users = await getUsers();
      return users.firstWhere((user) => user['id'] == id, orElse: () => {});
    } catch (e) {
      return null;
    }
  }

  // Récupérer tous les cours
  static Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final List<dynamic> jsonList = json.decode(_coursesJson);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Récupérer un cours par son ID
  static Future<Map<String, dynamic>?> getCourseById(int id) async {
    try {
      final courses = await getCourses();
      return courses.firstWhere(
        (course) => course['id'] == id,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }
}
