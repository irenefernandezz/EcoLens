class User {
  final int? id;
  final String username;
  final String password;
  final String email;
  final String avatar;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.email,
    this.avatar = 'lib/resources/profile.png',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'avatar': avatar,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      avatar: map['avatar'] ?? 'lib/resources/profile.png',
    );
  }
}
