class User {
  final String name;
  final String email;
  final String password;

  User({
    required this.name,
    required this.email,
    required this.password,
  });

  // fromJson method to map the response body into a User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  // Method to convert the User object into a Map (for sending in POST request)
  Map<String, String> toMap() {
    return {
      "name": name,
      "email": email,
      "password": password,
    };
  }
}
