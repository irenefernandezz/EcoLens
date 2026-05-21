//Comentarios añadidos por los usuarios
class EcoTip {
  final String? id;
  final String username;
  final String text;
  final DateTime timestamp;
  final String avatar;
  final Map<String, bool> likedBy; //Almacena qué usuarios han dado like

  EcoTip({
    this.id,
    required this.username,
    required this.text,
    required this.timestamp,
    required this.avatar,
    this.likedBy = const {},
  });

  int get likesCount => likedBy.length;

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'avatar': avatar,
      'likedBy': likedBy,
    };
  }

  factory EcoTip.fromMap(String id, Map<dynamic, dynamic> map) {
    return EcoTip(
      id: id,
      username: map['username'] ?? 'username',
      text: map['text'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      avatar: map['avatar'] ?? 'lib/resources/profile.png',
      likedBy: map['likedBy'] != null 
          ? Map<String, bool>.from(map['likedBy'] as Map) 
          : {},
    );
  }
}
