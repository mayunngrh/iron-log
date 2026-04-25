import '../../../../core/database/app_database.dart';
import '../models/session.dart';

class SessionRepository {
  final _db = AppDatabase.instance;

  Future<int> saveSession(Session session) async {
    final database = await _db.database;

    final sessionId = await database.insert('sessions', session.toMap());

    if (session.exercises.isNotEmpty) {
      for (final exercise in session.exercises) {
        await database.insert(
          'session_exercises',
          {
            ...exercise.toMap(),
            'sessionId': sessionId,
          },
        );
      }
    }

    return sessionId;
  }

  Future<Session?> getSession(int sessionId) async {
    final database = await _db.database;

    final sessionResult = await database.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (sessionResult.isEmpty) return null;

    final exercisesResult = await database.query(
      'session_exercises',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );

    final exercises = exercisesResult
        .map((e) => SessionExercise.fromMap(e))
        .toList();

    return Session.fromMap(sessionResult.first, exercises);
  }

  Future<List<Session>> getAllSessions() async {
    final database = await _db.database;

    final result = await database.query(
      'sessions',
      orderBy: 'date DESC',
    );

    final sessions = <Session>[];
    for (final sessionMap in result) {
      final sessionId = sessionMap['id'] as int;
      final exercisesResult = await database.query(
        'session_exercises',
        where: 'sessionId = ?',
        whereArgs: [sessionId],
      );

      final exercises = exercisesResult
          .map((e) => SessionExercise.fromMap(e))
          .toList();

      sessions.add(Session.fromMap(sessionMap, exercises));
    }

    return sessions;
  }

  Future<List<Session>> getSessionsByDate(DateTime date) async {
    final database = await _db.database;
    final dateStr = date.toIso8601String().split('T')[0];

    final result = await database.rawQuery(
      'SELECT * FROM sessions WHERE date LIKE ? ORDER BY date DESC',
      ['$dateStr%'],
    );

    final sessions = <Session>[];
    for (final sessionMap in result) {
      final sessionId = sessionMap['id'] as int;
      final exercisesResult = await database.query(
        'session_exercises',
        where: 'sessionId = ?',
        whereArgs: [sessionId],
      );

      final exercises = exercisesResult
          .map((e) => SessionExercise.fromMap(e))
          .toList();

      sessions.add(Session.fromMap(sessionMap, exercises));
    }

    return sessions;
  }

  Future<List<Session>> getRecentSessions({int limit = 5}) async {
    final database = await _db.database;

    final result = await database.query(
      'sessions',
      orderBy: 'date DESC',
      limit: limit,
    );

    final sessions = <Session>[];
    for (final sessionMap in result) {
      final sessionId = sessionMap['id'] as int;
      final exercisesResult = await database.query(
        'session_exercises',
        where: 'sessionId = ?',
        whereArgs: [sessionId],
      );

      final exercises = exercisesResult
          .map((e) => SessionExercise.fromMap(e))
          .toList();

      sessions.add(Session.fromMap(sessionMap, exercises));
    }

    return sessions;
  }

  Future<Map<String, double>> getPersonalRecords() async {
    final database = await _db.database;

    final result = await database.rawQuery(
      'SELECT exerciseName, MAX(maxWeightInSet) as pr FROM session_exercises GROUP BY exerciseName ORDER BY pr DESC',
    );

    final prMap = <String, double>{};
    for (final row in result) {
      prMap[row['exerciseName'] as String] = (row['pr'] as num).toDouble();
    }

    return prMap;
  }

  Future<double?> getPersonalRecordForExercise(String exerciseName) async {
    final database = await _db.database;

    final result = await database.rawQuery(
      'SELECT MAX(maxWeightInSet) as pr FROM session_exercises WHERE exerciseName = ?',
      [exerciseName],
    );

    if (result.isEmpty || result.first['pr'] == null) return null;
    return (result.first['pr'] as num).toDouble();
  }
}
