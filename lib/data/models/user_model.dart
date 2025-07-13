class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? age;
  final String? weight;
  final String? level;
  final String? goal;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.age,
    this.weight,
    this.level,
    this.goal,
  });

  factory UserModel.fromMap(Map<String, dynamic> profile) {
    return UserModel(
      id: _parseString(profile['UID']),
      name: _parseString(profile['name']),
      phone: _parseString(profile['phone']),
      email: _parseString(profile['email']),
      age: _parseString(profile['age']),
      weight: _parseString(profile['weight']),
      level: _parseString(profile['level']),
      goal: _parseString(profile['goal']),
    );
  }

  // Helper method to safely parse strings
  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  // Add copyWith method for easy updates
  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? age,
    String? weight,
    String? level,
    String? goal,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      level: level ?? this.level,
      goal: goal ?? this.goal,
    );
  }

  // Add toString for better debugging
  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, phone: $phone, email: $email, '
        'age: $age, weight: $weight, level: $level, goal: $goal}';
  }

  // Add equality and hashCode for state management
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          email == other.email &&
          age == other.age &&
          weight == other.weight &&
          level == other.level &&
          goal == other.goal;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      age.hashCode ^
      weight.hashCode ^
      level.hashCode ^
      goal.hashCode;
}
