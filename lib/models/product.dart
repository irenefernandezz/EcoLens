class Product {
  final int? id;
  final String barcode;
  final String nombre;
  final String imgUrl;

  Product({
    this.id,
    required this.barcode,
    required this.nombre,
    required this.imgUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'nombre': nombre,
      'img_url': imgUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      barcode: map['barcode'],
      nombre: map['nombre'],
      imgUrl: map['img_url'],
    );
  }
}
