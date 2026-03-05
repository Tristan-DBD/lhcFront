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
  final List<Map<String, dynamic>> progUri;
  final List<Map<String, dynamic>> payments;

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
    required this.progUri,
    required this.payments,
  });

  // Factory constructor pour créer un User depuis JSON
  factory User.fromJson(Map<String, dynamic> json) {
    // Gérer le cast du tableau stat correctement
    List<Map<String, dynamic>> statList = [];
    if (json['stat'] != null) {
      final statData = json['stat'] as List;
      statList = statData.map((item) => item as Map<String, dynamic>).toList();
    }

    List<Map<String, dynamic>> progUriList = [];
    if (json['progUri'] != null) {
      final progUriData = json['progUri'] as List;
      progUriList = progUriData
          .map((item) => item as Map<String, dynamic>)
          .toList();
    }

    List<Map<String, dynamic>> paymentList = [];
    if (json['payments'] != null) {
      final paymentData = json['payments'] as List;
      paymentList = paymentData
          .map((item) => item as Map<String, dynamic>)
          .toList();
    }

    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      role: json['role'] as String? ?? '',
      stat: statList,
      imageUri: json['imageUri'] as String? ?? 'default.png',
      progUri: progUriList,
      payments: paymentList,
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
      'payments': payments,
    };
  }

  // Getter pour le nom complet
  String get fullName => '$surname $name'.trim();

  // Méthode copyWith pour créer une copie avec certaines propriétés modifiées
  User copyWith({
    int? id,
    String? name,
    String? surname,
    String? email,
    String? phone,
    int? age,
    int? weight,
    String? role,
    List<Map<String, dynamic>>? stat,
    String? imageUri,
    List<Map<String, dynamic>>? progUri,
    List<Map<String, dynamic>>? payments,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      role: role ?? this.role,
      stat: stat ?? this.stat,
      imageUri: imageUri ?? this.imageUri,
      progUri: progUri ?? this.progUri,
      payments: payments ?? this.payments,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, surname: $surname, email: $email, phone: $phone, age: $age, weight: $weight, role: $role, stat: $stat, imageUri: $imageUri)';
  }
}
