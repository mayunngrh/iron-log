import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

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
      );
      await db.insert('workout_exercises', we.toMap());
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

    return rows.map((r) {
      final exercise = Exercise(
        id: r['exerciseId'] as int,
        name: r['name'] as String,
        category: r['category'] as String,
        muscleGroup: r['muscleGroup'] as String,
        type: r['type'] as String,
      );
      return WorkoutExercise(
        id: r['id'] as int,
        workoutId: r['workoutId'] as int,
        exercise: exercise,
        orderIndex: r['orderIndex'] as int,
        tag: r['tag'] as String? ?? exercise.autoTag,
      );
    }).toList();
  }
}
