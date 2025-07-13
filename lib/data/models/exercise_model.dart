import 'package:fitbliss/screens/onboarding/goal.dart';

// Extension for enum serialization/deserialization
extension ExerciseCategoryExtension on Goal {
  static Goal fromString(String name) {
    return Goal.values.firstWhere(
      (e) => e.name == name,
      orElse: () => Goal.improve_fitness, // default
    );
  }

  // Add a toJson method for consistency
  String toJson() => name;
}

// Exercise Model
class ExerciseModel {
  final int id;
  final String name;
  final String description;
  final String difficulty;
  final Goal category;
  final String image;
  final String duration;
  final int kcal;
  final int reps;
  final List<String> instructions; // Added
  final List<String> benefits; // Added

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.image,
    required this.duration,
    required this.kcal,
    required this.reps,
    required this.instructions, // Added
    required this.benefits, // Added
  });

  // Convert to JSON - use extension method for category
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'difficulty': difficulty,
    'category': category.toJson(),
    'image': image,
    'duration': duration,
    'kcal': kcal,
    'reps': reps,
    'instructions': instructions, // Added
    'benefits': benefits, // Added
  };

  // Create from JSON - add error handling
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExerciseModel(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
        difficulty: json['difficulty'] as String,
        category: ExerciseCategoryExtension.fromString(
          json['category'] as String,
        ),
        image: json['image'] as String,
        duration: json['duration'] as String,
        kcal: json['kcal'] as int,
        reps: json['reps'] as int,
        instructions: List<String>.from(json['instructions'] ?? []), // Added
        benefits: List<String>.from(json['benefits'] ?? []), // Added
      );
    } catch (e) {
      throw FormatException('Failed to parse ExerciseModel: $e');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Updated copyWith to include new fields
  ExerciseModel copyWith({
    int? id,
    String? name,
    String? description,
    String? difficulty,
    Goal? category,
    String? image,
    String? duration,
    int? kcal,
    int? reps,
    List<String>? instructions, // Added
    List<String>? benefits, // Added
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      image: image ?? this.image,
      duration: duration ?? this.duration,
      kcal: kcal ?? this.kcal,
      reps: reps ?? this.reps,
      instructions: instructions ?? this.instructions, // Added
      benefits: benefits ?? this.benefits, // Added
    );
  }

  @override
  String toString() {
    return 'ExerciseModel{id: $id, name: $name, category: ${category.name}}';
  }
}
