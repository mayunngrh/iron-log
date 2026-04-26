class SessionExercise {
  final int? id;
  final int sessionId;
  final String exerciseName;
  final int setsCompleted;
  final int totalReps;
  final double totalWeight;
  final double maxWeightInSet;

  const SessionExercise({
    this.id,
    required this.sessionId,
    required this.exerciseName,
    required this.setsCompleted,
    this.totalReps = 0,
    required this.totalWeight,
    required this.maxWeightInSet,
  });

  factory SessionExercise.fromMap(Map<String, dynamic> map) => SessionExercise(
        id: map['id'] as int?,
        sessionId: map['sessionId'] as int,
        exerciseName: map['exerciseName'] as String,
        setsCompleted: map['setsCompleted'] as int,
        totalReps: map['totalReps'] as int? ?? 0,
        totalWeight: (map['totalWeight'] as num).toDouble(),
        maxWeightInSet: (map['maxWeightInSet'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'sessionId': sessionId,
        'exerciseName': exerciseName,
        'setsCompleted': setsCompleted,
        'totalReps': totalReps,
        'totalWeight': totalWeight,
        'maxWeightInSet': maxWeightInSet,
      };
}

class Session {
  final int? id;
  final int workoutId;
  final String workoutName;
  final DateTime date;
  final int durationSeconds;
  final double totalWeightLifted;
  final int totalSetsCompleted;
  final int expGained;
  final List<SessionExercise> exercises;

  const Session({
    this.id,
    required this.workoutId,
    required this.workoutName,
    required this.date,
    required this.durationSeconds,
    required this.totalWeightLifted,
    required this.totalSetsCompleted,
    required this.expGained,
    this.exercises = const [],
  });

  factory Session.fromMap(
    Map<String, dynamic> map,
    List<SessionExercise> exercises,
  ) =>
      Session(
        id: map['id'] as int?,
        workoutId: map['workoutId'] as int,
        workoutName: map['workoutName'] as String,
        date: DateTime.parse(map['date'] as String),
        durationSeconds: map['durationSeconds'] as int,
        totalWeightLifted: (map['totalWeightLifted'] as num).toDouble(),
        totalSetsCompleted: map['totalSetsCompleted'] as int,
        expGained: map['expGained'] as int,
        exercises: exercises,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'workoutId': workoutId,
        'workoutName': workoutName,
        'date': date.toIso8601String(),
        'durationSeconds': durationSeconds,
        'totalWeightLifted': totalWeightLifted,
        'totalSetsCompleted': totalSetsCompleted,
        'expGained': expGained,
      };
}
