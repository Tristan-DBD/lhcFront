class UserRole {
  final String value;

  const UserRole(this.value);

  factory UserRole.fromString(String? role) {
    return UserRole((role ?? '').toUpperCase());
  }

  bool get isAdmin => value == 'ADMIN';
  bool get isCoach => value == 'COACH';
  bool get isAthleteFull => value == 'ATHLETE_FULL';
  bool get isAthleteProg => value == 'ATHLETE_PROG';
  bool get isAthleteCo => value == 'ATHLETE_CO';

  // Helper properties
  bool get isAthlete => isAthleteFull || isAthleteProg || isAthleteCo;

  String get label {
    if (isAdmin) return 'Administrateur';
    if (isCoach) return 'Coach';
    if (isAthleteFull) return 'Programme + Collectif';
    if (isAthleteProg) return 'Programme';
    if (isAthleteCo) return 'Collectif';
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRole &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
