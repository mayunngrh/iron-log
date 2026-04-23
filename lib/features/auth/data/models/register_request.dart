class RegisterRequest {
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String username;

  const RegisterRequest({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': '$firstName $lastName',
        'password': password,
        'username': username,
      };
}
