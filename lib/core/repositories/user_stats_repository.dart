import '../database/app_database.dart';
import '../models/user_stats.dart';

class UserStatsRepository {
  final _db = AppDatabase.instance;

  Future<UserStats?> getUserStats(String username) async {
    final database = await _db.database;
    final result = await database.query(
      'user_stats',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isEmpty) return null;
    return UserStats.fromMap(result.first);
  }

  Future<UserStats> createUserStats({
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    final database = await _db.database;
    final userStats = UserStats(
      username: username,
      firstName: firstName,
      lastName: lastName,
      createdAt: DateTime.now(),
    );

    final id = await database.insert('user_stats', userStats.toMap());
    return UserStats(
      id: id,
      username: username,
      firstName: firstName,
      lastName: lastName,
      createdAt: userStats.createdAt,
    );
  }

  Future<void> addExp(String username, int expGained) async {
    final database = await _db.database;
    final userStats = await getUserStats(username);
    if (userStats == null) return;

    final newExp = userStats.totalExp + expGained;
    int newLevel = userStats.level;

    while (newLevel < 50 && newExp >= userStats.getExpForLevel(newLevel + 1)) {
      newLevel++;
    }

    await database.update(
      'user_stats',
      {
        'totalExp': newExp,
        'level': newLevel,
      },
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<void> updateUserStats(UserStats userStats) async {
    final database = await _db.database;
    await database.update(
      'user_stats',
      userStats.toMap(),
      where: 'id = ?',
      whereArgs: [userStats.id],
    );
  }
}
