class RegisterRequest {
  final String email;
  final String fullName;
  final String password;
  final String username;

  const RegisterRequest({
    required this.email,
    required this.fullName,
    required this.password,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
        'password': password,
        'username': username,
      };
}
