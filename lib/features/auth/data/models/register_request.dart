class SignUpRequest {
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String username;

  const SignUpRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'username': username,
      };
}

class SignUpResponse {
  final int id;
  final String username;
  final String firstName;
  final String lastName;

  const SignUpResponse({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) => SignUpResponse(
        id: json['id'] as int,
        username: json['username'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
      );
}
