import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

class UserFollowRepository {
  final _db = AppDatabase.instance;

  Future<void> followUser(String followerUsername, String followingUsername) async {
    final db = await _db.database;
    await db.insert(
      'user_follows',
      {
        'followerUsername': followerUsername,
        'followingUsername': followingUsername,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> unfollowUser(String followerUsername, String followingUsername) async {
    final db = await _db.database;
    await db.delete(
      'user_follows',
      where: 'followerUsername = ? AND followingUsername = ?',
      whereArgs: [followerUsername, followingUsername],
    );
  }

  Future<bool> isFollowing(String followerUsername, String followingUsername) async {
    final db = await _db.database;
    final result = await db.query(
      'user_follows',
      where: 'followerUsername = ? AND followingUsername = ?',
      whereArgs: [followerUsername, followingUsername],
    );
    return result.isNotEmpty;
  }

  Future<List<String>> getFollowers(String username) async {
    final db = await _db.database;
    final result = await db.query(
      'user_follows',
      where: 'followingUsername = ?',
      whereArgs: [username],
    );
    return result.map((m) => m['followerUsername'] as String).toList();
  }

  Future<List<String>> getFollowing(String username) async {
    final db = await _db.database;
    final result = await db.query(
      'user_follows',
      where: 'followerUsername = ?',
      whereArgs: [username],
    );
    return result.map((m) => m['followingUsername'] as String).toList();
  }

  Future<int> getFollowerCount(String username) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_follows WHERE followingUsername = ?',
      [username],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getFollowingCount(String username) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_follows WHERE followerUsername = ?',
      [username],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
