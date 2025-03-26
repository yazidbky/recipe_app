class LoginJson {
  final String email;
  final String password;

  LoginJson({
    required this.email,
    required this.password,
  });

  // fromJson method to map the response body into a User object
  factory LoginJson.fromJson(Map<String, dynamic> json) {
    return LoginJson(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
  // Method to convert the User object into a Map (for sending in POST request)
  Map<String, String> toMap() {
    return {
      "email": email,
      "password": password,
    };
  }
}
