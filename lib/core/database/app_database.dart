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
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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

    await db.execute('''
      CREATE TABLE exercise_sets (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutExerciseId INTEGER NOT NULL,
        setNumber         INTEGER NOT NULL,
        reps              INTEGER NOT NULL DEFAULT 0,
        weight            REAL    NOT NULL DEFAULT 0.0,
        FOREIGN KEY (workoutExerciseId) REFERENCES workout_exercises(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE user_stats (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        username  TEXT    NOT NULL UNIQUE,
        firstName TEXT    NOT NULL,
        lastName  TEXT    NOT NULL,
        level     INTEGER NOT NULL DEFAULT 1,
        totalExp  INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId           INTEGER NOT NULL,
        workoutName         TEXT    NOT NULL,
        date                TEXT    NOT NULL,
        durationSeconds     INTEGER NOT NULL,
        totalWeightLifted   REAL    NOT NULL,
        totalSetsCompleted  INTEGER NOT NULL,
        expGained           INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (workoutId) REFERENCES workouts(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE session_exercises (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId        INTEGER NOT NULL,
        exerciseName     TEXT    NOT NULL,
        setsCompleted    INTEGER NOT NULL,
        totalWeight      REAL    NOT NULL,
        maxWeightInSet   REAL    NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES sessions(id) ON DELETE CASCADE
      )
    ''');

    final batch = db.batch();
    for (final e in ExerciseSeeds.all) {
      batch.insert('exercises', e);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE exercise_sets (
          id                INTEGER PRIMARY KEY AUTOINCREMENT,
          workoutExerciseId INTEGER NOT NULL,
          setNumber         INTEGER NOT NULL,
          reps              INTEGER NOT NULL DEFAULT 0,
          weight            REAL    NOT NULL DEFAULT 0.0,
          FOREIGN KEY (workoutExerciseId) REFERENCES workout_exercises(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE user_stats (
          id        INTEGER PRIMARY KEY AUTOINCREMENT,
          username  TEXT    NOT NULL UNIQUE,
          firstName TEXT    NOT NULL,
          lastName  TEXT    NOT NULL,
          level     INTEGER NOT NULL DEFAULT 1,
          totalExp  INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT    NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE sessions (
          id                  INTEGER PRIMARY KEY AUTOINCREMENT,
          workoutId           INTEGER NOT NULL,
          workoutName         TEXT    NOT NULL,
          date                TEXT    NOT NULL,
          durationSeconds     INTEGER NOT NULL,
          totalWeightLifted   REAL    NOT NULL,
          totalSetsCompleted  INTEGER NOT NULL,
          expGained           INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (workoutId) REFERENCES workouts(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE session_exercises (
          id               INTEGER PRIMARY KEY AUTOINCREMENT,
          sessionId        INTEGER NOT NULL,
          exerciseName     TEXT    NOT NULL,
          setsCompleted    INTEGER NOT NULL,
          totalWeight      REAL    NOT NULL,
          maxWeightInSet   REAL    NOT NULL,
          FOREIGN KEY (sessionId) REFERENCES sessions(id) ON DELETE CASCADE
        )
      ''');
    }
  }
}
