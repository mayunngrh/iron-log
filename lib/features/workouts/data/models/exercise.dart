class Exercise {
  final int id;
  final String name;
  final String category;
  final String muscleGroup;
  final String type;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroup,
    required this.type,
  });

  factory Exercise.fromMap(Map<String, dynamic> m) => Exercise(
        id: m['id'] as int,
        name: m['name'] as String,
        category: m['category'] as String,
        muscleGroup: m['muscleGroup'] as String,
        type: m['type'] as String,
      );

  String get autoTag => '${muscleGroup.toUpperCase()} • $type';
}
