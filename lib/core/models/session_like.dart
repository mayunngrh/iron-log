class SessionLike {
  final int? id;
  final int sessionId;
  final String username;
  final DateTime createdAt;

  const SessionLike({
    this.id,
    required this.sessionId,
    required this.username,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'username': username,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SessionLike.fromMap(Map<String, dynamic> map) {
    return SessionLike(
      id: map['id'] as int?,
      sessionId: map['sessionId'] as int,
      username: map['username'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
