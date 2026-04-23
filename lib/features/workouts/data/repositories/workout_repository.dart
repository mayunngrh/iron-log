import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../models/exercise.dart';
import '../models/workout.dart' show Workout, WorkoutExercise, ExerciseSet;

class WorkoutRepository {
  Future<Database> get _db => AppDatabase.instance.database;

  // ── Workouts ─────────────────────────────────────────────────────────────

  Future<List<Workout>> getAllWorkouts() async {
    final db = await _db;
    final rows = await db.query('workouts', orderBy: 'createdAt DESC');
    final workouts = <Workout>[];
    for (final row in rows) {
      final exercises = await _loadExercises(db, row['id'] as int);
      workouts.add(Workout.fromMap(row, exercises));
    }
    return workouts;
  }

  Future<int> saveWorkout(Workout workout, List<WorkoutExercise> exercises) async {
    final db = await _db;
    final workoutId = await db.insert('workouts', workout.toMap());
    for (var i = 0; i < exercises.length; i++) {
      final we = WorkoutExercise(
        workoutId: workoutId,
        exercise: exercises[i].exercise,
        orderIndex: i,
        tag: exercises[i].tag,
        sets: exercises[i].sets,
      );
      final weId = await db.insert('workout_exercises', we.toMap());

      final batch = db.batch();
      for (var s = 0; s < we.sets.length; s++) {
        final set = ExerciseSet(
          workoutExerciseId: weId,
          setNumber: s + 1,
          reps: we.sets[s].reps,
          weight: we.sets[s].weight,
        );
        batch.insert('exercise_sets', set.toMap());
      }
      await batch.commit(noResult: true);
    }
    return workoutId;
  }

  Future<void> deleteWorkout(int id) async {
    final db = await _db;
    await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  // ── Exercises ─────────────────────────────────────────────────────────────

  Future<List<Exercise>> getAllExercises() async {
    final db = await _db;
    final rows = await db.query('exercises', orderBy: 'muscleGroup ASC, name ASC');
    return rows.map(Exercise.fromMap).toList();
  }

  Future<List<Exercise>> searchExercises(String query) async {
    final db = await _db;
    final rows = await db.query(
      'exercises',
      where: 'name LIKE ?',
      whereArgs: ['%${query.toUpperCase()}%'],
      orderBy: 'muscleGroup ASC, name ASC',
    );
    return rows.map(Exercise.fromMap).toList();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<List<WorkoutExercise>> _loadExercises(Database db, int workoutId) async {
    final rows = await db.rawQuery('''
      SELECT
        we.id, we.workoutId, we.exerciseId, we.orderIndex, we.tag,
        e.name, e.category, e.muscleGroup, e.type
      FROM workout_exercises we
      JOIN exercises e ON we.exerciseId = e.id
      WHERE we.workoutId = ?
      ORDER BY we.orderIndex ASC
    ''', [workoutId]);

    final result = <WorkoutExercise>[];
    for (final r in rows) {
      final weId = r['id'] as int;
      final exercise = Exercise(
        id: r['exerciseId'] as int,
        name: r['name'] as String,
        category: r['category'] as String,
        muscleGroup: r['muscleGroup'] as String,
        type: r['type'] as String,
      );

      final setRows = await db.query(
        'exercise_sets',
        where: 'workoutExerciseId = ?',
        whereArgs: [weId],
        orderBy: 'setNumber ASC',
      );
      final sets = setRows.map(ExerciseSet.fromMap).toList();

      result.add(WorkoutExercise(
        id: weId,
        workoutId: r['workoutId'] as int,
        exercise: exercise,
        orderIndex: r['orderIndex'] as int,
        tag: r['tag'] as String? ?? exercise.autoTag,
        sets: sets,
      ));
    }
    return result;
  }
}
