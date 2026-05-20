import 'dart:convert';

class SharedSession {
  final int? id;
  final String username;
  final String firstName;
  final String lastName;
  final String workoutName;
  final String? description;
  final DateTime date;
  final int durationSeconds;
  final double totalWeightLifted;
  final int totalSetsCompleted;
  final String? methodology;
  final List<Map<String, dynamic>> exercises;
  final DateTime createdAt;
  final String? sessionPhotoPath;

  SharedSession({
    this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.workoutName,
    this.description,
    required this.date,
    required this.durationSeconds,
    required this.totalWeightLifted,
    required this.totalSetsCompleted,
    this.methodology,
    required this.exercises,
    required this.createdAt,
    this.sessionPhotoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'workoutName': workoutName,
      'description': description,
      'date': date.toIso8601String(),
      'durationSeconds': durationSeconds,
      'totalWeightLifted': totalWeightLifted,
      'totalSetsCompleted': totalSetsCompleted,
      'methodology': methodology,
      'exercises': jsonEncode(exercises),
      'createdAt': createdAt.toIso8601String(),
      'sessionPhotoPath': sessionPhotoPath,
    };
  }

  factory SharedSession.fromMap(Map<String, dynamic> map) {
    return SharedSession(
      id: map['id'] as int?,
      username: map['username'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      workoutName: map['workoutName'] as String,
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      durationSeconds: map['durationSeconds'] as int,
      totalWeightLifted: (map['totalWeightLifted'] as num).toDouble(),
      totalSetsCompleted: map['totalSetsCompleted'] as int,
      methodology: map['methodology'] as String?,
      exercises: List<Map<String, dynamic>>.from(
        jsonDecode(map['exercises'] as String) as List,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      sessionPhotoPath: map['sessionPhotoPath'] as String?,
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String get userDisplayName => '$firstName $lastName';
}
