enum Rank {
  bronze,
  silver,
  gold,
  platinum,
  mythical,
}

enum FitnessGoal {
  loseWeight,
  buildMuscle,
  maintain,
  improveEndurance,
}

extension FitnessGoalExtension on FitnessGoal {
  String get label {
    switch (this) {
      case FitnessGoal.loseWeight:
        return 'LOSE WEIGHT';
      case FitnessGoal.buildMuscle:
        return 'BUILD MUSCLE';
      case FitnessGoal.maintain:
        return 'MAINTAIN';
      case FitnessGoal.improveEndurance:
        return 'IMPROVE ENDURANCE';
    }
  }

  String get value {
    switch (this) {
      case FitnessGoal.loseWeight:
        return 'LOSE_WEIGHT';
      case FitnessGoal.buildMuscle:
        return 'BUILD_MUSCLE';
      case FitnessGoal.maintain:
        return 'MAINTAIN';
      case FitnessGoal.improveEndurance:
        return 'IMPROVE_ENDURANCE';
    }
  }

  static FitnessGoal? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'LOSE_WEIGHT':
        return FitnessGoal.loseWeight;
      case 'BUILD_MUSCLE':
        return FitnessGoal.buildMuscle;
      case 'MAINTAIN':
        return FitnessGoal.maintain;
      case 'IMPROVE_ENDURANCE':
        return FitnessGoal.improveEndurance;
      default:
        return null;
    }
  }
}

enum Gender {
  male,
  female,
  other,
}

extension GenderExtension on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return 'MALE';
      case Gender.female:
        return 'FEMALE';
      case Gender.other:
        return 'OTHER';
    }
  }

  String get value {
    switch (this) {
      case Gender.male:
        return 'MALE';
      case Gender.female:
        return 'FEMALE';
      case Gender.other:
        return 'OTHER';
    }
  }

  static Gender? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'MALE':
        return Gender.male;
      case 'FEMALE':
        return Gender.female;
      case 'OTHER':
        return Gender.other;
      default:
        return null;
    }
  }
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
  final double? height;
  final double? weight;
  final int? age;
  final Gender? gender;
  final double? bodyFatPercentage;
  final FitnessGoal? fitnessGoal;

  const UserStats({
    this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.level = 1,
    this.totalExp = 0,
    required this.createdAt,
    this.height,
    this.weight,
    this.age,
    this.gender,
    this.bodyFatPercentage,
    this.fitnessGoal,
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

  double? get bmi {
    if (weight == null || height == null) return null;
    return weight! / ((height! / 100) * (height! / 100));
  }

  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    if (bmiValue < 18.5) return 'UNDERWEIGHT';
    if (bmiValue < 25) return 'NORMAL';
    if (bmiValue < 30) return 'OVERWEIGHT';
    return 'OBESE';
  }

  factory UserStats.fromMap(Map<String, dynamic> map) => UserStats(
        id: map['id'] as int?,
        username: map['username'] as String,
        firstName: map['firstName'] as String,
        lastName: map['lastName'] as String,
        level: map['level'] as int? ?? 1,
        totalExp: map['totalExp'] as int? ?? 0,
        createdAt: DateTime.parse(map['createdAt'] as String),
        height: (map['height'] as num?)?.toDouble(),
        weight: (map['weight'] as num?)?.toDouble(),
        age: map['age'] as int?,
        gender: GenderExtension.fromString(map['gender'] as String?),
        bodyFatPercentage: (map['bodyFatPercentage'] as num?)?.toDouble(),
        fitnessGoal: FitnessGoalExtension.fromString(map['fitnessGoal'] as String?),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'level': level,
        'totalExp': totalExp,
        'createdAt': createdAt.toIso8601String(),
        if (height != null) 'height': height,
        if (weight != null) 'weight': weight,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender?.value,
        if (bodyFatPercentage != null) 'bodyFatPercentage': bodyFatPercentage,
        if (fitnessGoal != null) 'fitnessGoal': fitnessGoal?.value,
      };
}
