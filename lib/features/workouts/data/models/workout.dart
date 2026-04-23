import 'exercise.dart';

class ExerciseSet {
  final int? id;
  final int workoutExerciseId;
  final int setNumber;
  final int reps;
  final double weight;

  const ExerciseSet({
    this.id,
    required this.workoutExerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  factory ExerciseSet.fromMap(Map<String, dynamic> m) => ExerciseSet(
        id: m['id'] as int?,
        workoutExerciseId: m['workoutExerciseId'] as int,
        setNumber: m['setNumber'] as int,
        reps: m['reps'] as int,
        weight: (m['weight'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'workoutExerciseId': workoutExerciseId,
        'setNumber': setNumber,
        'reps': reps,
        'weight': weight,
      };
}

class WorkoutExercise {
  final int? id;
  final int workoutId;
  final Exercise exercise;
  final int orderIndex;
  final String tag;
  final List<ExerciseSet> sets;

  const WorkoutExercise({
    this.id,
    required this.workoutId,
    required this.exercise,
    required this.orderIndex,
    required this.tag,
    this.sets = const [],
  });

  String get setsLabel {
    if (sets.isEmpty) return '';
    final uniform = sets.every(
      (s) => s.reps == sets.first.reps && s.weight == sets.first.weight,
    );
    if (uniform) {
      final weight = sets.first.weight;
      return '${sets.length} × ${sets.first.reps} @ ${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg';
    }
    return '${sets.length} SET${sets.length == 1 ? '' : 'S'}';
  }

  String getSetsSummary() {
    if (sets.isEmpty) return '';
    return sets
        .map((s) =>
            '${s.reps}×${s.weight.toStringAsFixed(s.weight % 1 == 0 ? 0 : 1)}')
        .join(' / ');
  }

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
