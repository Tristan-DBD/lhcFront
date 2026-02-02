class User {
  final int id;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final int age;
  final int weight;
  final String role;
  final List<Map<String, dynamic>> stat;
  final String imageUri;
  final String? progUri;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.age,
    required this.weight,
    required this.role,
    required this.stat,
    required this.imageUri,
    this.progUri,
  });

  // Factory constructor pour créer un User depuis JSON
  factory User.fromJson(Map<String, dynamic> json) {
    // Gérer le cast du tableau stat correctement
    List<Map<String, dynamic>> statList = [];
    if (json['stat'] != null) {
      final statData = json['stat'] as List;
      statList = statData.map((item) => item as Map<String, dynamic>).toList();
    }

    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      role: json['role'] as String? ?? '',
      stat: statList,
      imageUri: json['imageUri'] as String? ?? 'default.png',
      progUri: json['progUri'] as String?,
    );
  }

  // Méthode pour convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'age': age,
      'weight': weight,
      'role': role,
      'stat': stat,
      'imageUri': imageUri,
      'progUri': progUri,
    };
  }

  // Getter pour le nom complet
  String get fullName => '$name $surname'.trim();

  @override
  String toString() {
    return 'User(id: $id, name: $name, surname: $surname, email: $email, phone: $phone, age: $age, weight: $weight, role: $role, stat: $stat, imageUri: $imageUri)';
  }
}
