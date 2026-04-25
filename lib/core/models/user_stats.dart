enum Rank {
  bronze,
  silver,
  gold,
  platinum,
  mythical,
}

extension RankExtension on Rank {
  String get label {
    switch (this) {
      case Rank.bronze:
        return 'BRONZE';
      case Rank.silver:
        return 'SILVER';
      case Rank.gold:
        return 'GOLD';
      case Rank.platinum:
        return 'PLATINUM';
      case Rank.mythical:
        return 'MYTHICAL';
    }
  }

  int get minLevel {
    switch (this) {
      case Rank.bronze:
        return 1;
      case Rank.silver:
        return 11;
      case Rank.gold:
        return 21;
      case Rank.platinum:
        return 31;
      case Rank.mythical:
        return 41;
    }
  }
}

class UserStats {
  final int? id;
  final String username;
  final String firstName;
  final String lastName;
  final int level;
  final int totalExp;
  final DateTime createdAt;

  const UserStats({
    this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.level = 1,
    this.totalExp = 0,
    required this.createdAt,
  });

  int getExpForLevel(int targetLevel) {
    int exp = 0;
    for (int i = 1; i < targetLevel; i++) {
      exp += 1000 + (i - 1) * 500;
    }
    return exp;
  }

  int getExpForNextLevel() => getExpForLevel(level + 1);

  int getExpProgress() => totalExp - getExpForLevel(level);

  int getExpNeededForNextLevel() {
    final nextLevelExp = getExpForNextLevel();
    final currentLevelExp = getExpForLevel(level);
    return nextLevelExp - currentLevelExp;
  }

  Rank getRank() {
    if (level <= 10) return Rank.bronze;
    if (level <= 20) return Rank.silver;
    if (level <= 30) return Rank.gold;
    if (level <= 40) return Rank.platinum;
    return Rank.mythical;
  }

  factory UserStats.fromMap(Map<String, dynamic> map) => UserStats(
        id: map['id'] as int?,
        username: map['username'] as String,
        firstName: map['firstName'] as String,
        lastName: map['lastName'] as String,
        level: map['level'] as int? ?? 1,
        totalExp: map['totalExp'] as int? ?? 0,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'level': level,
        'totalExp': totalExp,
        'createdAt': createdAt.toIso8601String(),
      };
}
