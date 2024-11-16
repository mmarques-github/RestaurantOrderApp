class User {
  final String id;
  final String username;
  final String type;
  final String password;

  User({required this.id, required this.username, required this.type, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      type: json['type'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'type': type,
      'password': password,
    };
  }
}
