import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'exercise_seeds.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'ironlog.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT    NOT NULL,
        category     TEXT    NOT NULL,
        muscleGroup  TEXT    NOT NULL,
        type         TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        name              TEXT    NOT NULL,
        methodology       TEXT    NOT NULL DEFAULT 'STRENGTH',
        estimatedDuration INTEGER NOT NULL DEFAULT 60,
        notes             TEXT,
        createdAt         TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_exercises (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId   INTEGER NOT NULL,
        exerciseId  INTEGER NOT NULL,
        orderIndex  INTEGER NOT NULL,
        tag         TEXT,
        FOREIGN KEY (workoutId)  REFERENCES workouts(id)  ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises(id)
      )
    ''');

    final batch = db.batch();
    for (final e in ExerciseSeeds.all) {
      batch.insert('exercises', e);
    }
    await batch.commit(noResult: true);
  }
}
