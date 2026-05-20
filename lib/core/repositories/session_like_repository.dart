import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

class SessionLikeRepository {
  final _db = AppDatabase.instance;

  Future<void> likeSession(int sessionId, String username) async {
    final db = await _db.database;
    await db.insert(
      'session_likes',
      {
        'sessionId': sessionId,
        'username': username,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> unlikeSession(int sessionId, String username) async {
    final db = await _db.database;
    await db.delete(
      'session_likes',
      where: 'sessionId = ? AND username = ?',
      whereArgs: [sessionId, username],
    );
  }

  Future<bool> isLiked(int sessionId, String username) async {
    final db = await _db.database;
    final result = await db.query(
      'session_likes',
      where: 'sessionId = ? AND username = ?',
      whereArgs: [sessionId, username],
    );
    return result.isNotEmpty;
  }

  Future<int> getLikeCount(int sessionId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM session_likes WHERE sessionId = ?',
      [sessionId],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
