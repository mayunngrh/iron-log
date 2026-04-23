import 'exercise.dart';

class WorkoutExercise {
  final int? id;
  final int workoutId;
  final Exercise exercise;
  final int orderIndex;
  final String tag;

  const WorkoutExercise({
    this.id,
    required this.workoutId,
    required this.exercise,
    required this.orderIndex,
    required this.tag,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'workoutId': workoutId,
        'exerciseId': exercise.id,
        'orderIndex': orderIndex,
        'tag': tag,
      };
}

class Workout {
  final int? id;
  final String name;
  final String methodology;
  final int estimatedDuration;
  final String? notes;
  final DateTime createdAt;
  final List<WorkoutExercise> exercises;

  const Workout({
    this.id,
    required this.name,
    required this.methodology,
    required this.estimatedDuration,
    this.notes,
    required this.createdAt,
    this.exercises = const [],
  });

  int get exerciseCount => exercises.length;

  factory Workout.fromMap(
    Map<String, dynamic> m,
    List<WorkoutExercise> exercises,
  ) =>
      Workout(
        id: m['id'] as int,
        name: m['name'] as String,
        methodology: m['methodology'] as String,
        estimatedDuration: m['estimatedDuration'] as int,
        notes: m['notes'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
        exercises: exercises,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'methodology': methodology,
        'estimatedDuration': estimatedDuration,
        if (notes != null) 'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };
}
