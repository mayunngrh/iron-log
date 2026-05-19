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
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Check if migration to v5 was applied
    try {
      final result = await db.rawQuery('PRAGMA table_info(user_stats)');
      final hasHeightColumn = result.any((col) => col['name'] == 'height');

      if (!hasHeightColumn) {
        // Migration didn't happen, apply it manually
        await db.execute('ALTER TABLE user_stats ADD COLUMN height REAL');
        await db.execute('ALTER TABLE user_stats ADD COLUMN weight REAL');
        await db.execute('ALTER TABLE user_stats ADD COLUMN age INTEGER');
        await db.execute('ALTER TABLE user_stats ADD COLUMN gender TEXT');
        await db.execute('ALTER TABLE user_stats ADD COLUMN bodyFatPercentage REAL');
        await db.execute('ALTER TABLE user_stats ADD COLUMN fitnessGoal TEXT');

        // Add bodyweight exercises if not present
        final batch = db.batch();
        for (final e in ExerciseSeeds.bodyweightExercises) {
          batch.insert('exercises', e, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
        await batch.commit(noResult: true);
      }
    } catch (e) {
      // Silently ignore errors during migration check
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT    NOT NULL,
        category     TEXT    NOT NULL,
        muscleGroup  TEXT    NOT NULL,
        type         TEXT    NOT NULL,
        equipment    TEXT    NOT NULL DEFAULT 'FREE_WEIGHT'
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
        createdAt TEXT    NOT NULL,
        height REAL,
        weight REAL,
        age INTEGER,
        gender TEXT,
        bodyFatPercentage REAL,
        fitnessGoal TEXT,
        profilePhotoPath TEXT
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
        totalReps        INTEGER NOT NULL DEFAULT 0,
        totalWeight      REAL    NOT NULL,
        maxWeightInSet   REAL    NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES sessions(id) ON DELETE CASCADE
      )
    ''');

    final batch = db.batch();
    for (final e in ExerciseSeeds.all) {
      batch.insert('exercises', e);
    }
    for (final e in ExerciseSeeds.bodyweightExercises) {
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
          totalReps        INTEGER NOT NULL DEFAULT 0,
          totalWeight      REAL    NOT NULL,
          maxWeightInSet   REAL    NOT NULL,
          FOREIGN KEY (sessionId) REFERENCES sessions(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE session_exercises ADD COLUMN totalReps INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 5) {
      // Add body metrics columns to user_stats
      await db.execute(
        'ALTER TABLE user_stats ADD COLUMN height REAL',
      );
      await db.execute(
        'ALTER TABLE user_stats ADD COLUMN weight REAL',
      );
      await db.execute(
        'ALTER TABLE user_stats ADD COLUMN age INTEGER',
      );
      await db.execute(
        'ALTER TABLE user_stats ADD COLUMN gender TEXT',
      );
      await db.execute(
        'ALTER TABLE user_stats ADD COLUMN bodyFatPercentage REAL',
      );
      await db.execute(
        'ALTER TABLE user_stats ADD COLUMN fitnessGoal TEXT',
      );

      // Add bodyweight exercises
      final batch = db.batch();
      for (final e in ExerciseSeeds.bodyweightExercises) {
        batch.insert('exercises', e);
      }
      await batch.commit(noResult: true);
    }
    if (oldVersion < 6) {
      await db.execute(
        'ALTER TABLE user_stats ADD COLUMN profilePhotoPath TEXT',
      );
    }
    if (oldVersion < 7) {
      await db.execute(
        'ALTER TABLE exercises ADD COLUMN equipment TEXT NOT NULL DEFAULT "FREE_WEIGHT"',
      );
    }
  }
}
