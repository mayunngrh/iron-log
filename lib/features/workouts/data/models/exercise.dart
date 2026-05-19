class Exercise {
  final int id;
  final String name;
  final String category;
  final String muscleGroup;
  final String type;
  final String equipment;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroup,
    required this.type,
    this.equipment = 'FREE_WEIGHT',
  });

  factory Exercise.fromMap(Map<String, dynamic> m) => Exercise(
        id: m['id'] as int,
        name: m['name'] as String,
        category: m['category'] as String,
        muscleGroup: m['muscleGroup'] as String,
        type: m['type'] as String,
        equipment: m['equipment'] as String? ?? 'FREE_WEIGHT',
      );

  bool get isBodyweight => equipment == 'BODYWEIGHT';

  String get autoTag => '${muscleGroup.toUpperCase()} • $type';
}
