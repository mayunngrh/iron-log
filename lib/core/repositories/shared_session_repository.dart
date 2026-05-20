import '../database/app_database.dart';
import '../models/shared_session.dart';

class SharedSessionRepository {
  final _db = AppDatabase.instance;

  Future<void> shareSession(SharedSession session) async {
    final db = await _db.database;
    await db.insert('shared_sessions', session.toMap());
  }

  Future<List<SharedSession>> getAllSharedSessions() async {
    final db = await _db.database;
    final maps = await db.query(
      'shared_sessions',
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => SharedSession.fromMap(m)).toList();
  }

  Future<List<SharedSession>> searchSessions(String query) async {
    final db = await _db.database;
    final maps = await db.query(
      'shared_sessions',
      where:
          'workoutName LIKE ? OR firstName LIKE ? OR lastName LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => SharedSession.fromMap(m)).toList();
  }

  Future<List<SharedSession>> getUserSharedSessions(String username) async {
    final db = await _db.database;
    final maps = await db.query(
      'shared_sessions',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => SharedSession.fromMap(m)).toList();
  }

  Future<void> deleteSharedSession(int id) async {
    final db = await _db.database;
    await db.delete(
      'shared_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
