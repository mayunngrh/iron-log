class UserFollow {
  final int? id;
  final String followerUsername;
  final String followingUsername;
  final DateTime createdAt;

  const UserFollow({
    this.id,
    required this.followerUsername,
    required this.followingUsername,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'followerUsername': followerUsername,
      'followingUsername': followingUsername,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserFollow.fromMap(Map<String, dynamic> map) {
    return UserFollow(
      id: map['id'] as int?,
      followerUsername: map['followerUsername'] as String,
      followingUsername: map['followingUsername'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
