class Product_user {
  final int? id;
  final int user_id;
  final int product_id;
  final DateTime timestamp;

  Product_user({
    this.id,
    required this.user_id,
    required this.product_id,
    required this.timestamp,
  });

  // Para insertar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': user_id,
      'product_id': product_id,
      'fecha_scan': timestamp.toIso8601String(),
    };
  }

  factory Product_user.fromMap(Map<String, dynamic> map) {
    return Product_user(
      id: map['id'],
      user_id: map['user_id'],
      product_id: map['product_id'],
      timestamp: DateTime.parse(map['fecha_scan']),
    );
  }
}
