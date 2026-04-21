class ProductResponse {

  String name_en;
  String name_es;
  String brand;
  String image_url;
  int additives_count;
  int palm_oil_count;
  String ingredients_text;
  String ecoscore_grade;
  int nova_group;

 Agribalyse agribalyse;
 Packaging packaging;

 ProductResponse({
   required this.name_en,
   required this.name_es,
   required this.brand,
   required this.image_url,
   required this.nova_group,
   required this.agribalyse,
   required this.packaging,
   required this.additives_count,
   required this.palm_oil_count,
   required this.ingredients_text,
   required this.ecoscore_grade,
});

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? {};


    final ecoscoreData = product['ecoscore_data'] ?? {};
    final agribalyseData = ecoscoreData['agribalyse'] ?? {};

    return ProductResponse(
      name_en: product['product_name_en'] ?? "",
      name_es: product['product_name_es'] ?? product['product_name'] ?? "",
      brand: product['brands'] ?? "Unknown Brand",
      image_url: product['image_url'] ?? "",
      nova_group: product['nova_group'] ?? 0,
      additives_count: product['additives_n'] ?? -1,
      palm_oil_count: product['ingredients_from_or_that_may_be_from_palm_oil_n'] ?? -1,
      ingredients_text: product['ingredients_text'] ?? "",
      ecoscore_grade: product['ecoscore_grade'] ?? "",



      agribalyse: Agribalyse.fromJson(agribalyseData),
      packaging: Packaging.fromJson(product),
    );
  }

}

class Agribalyse {
  double co2Total;

  double co2Agriculture;
  double co2Packaging;
  double co2Transport;
  double co2Processing;

  Agribalyse({
    required this.co2Total,
    required this.co2Agriculture,
    required this.co2Packaging,
    required this.co2Transport,
    required this.co2Processing,
  });

  factory Agribalyse.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? -1;
      return -1;
    }

    return Agribalyse(
      co2Total: parseDouble(json['co2_total']),
      co2Agriculture: parseDouble(json['co2_agriculture']),
      co2Packaging: parseDouble(json['co2_packaging']),
      co2Transport: parseDouble(json['co2_transportation']),
      co2Processing: parseDouble(json['co2_processing']),
    );
  }
}

class Packaging {
  int nonRecyclable = 0;
  List<String> materials = [];
  bool isUnknown = false;

  Packaging({
    required this.nonRecyclable,
    required this.materials,
    required this.isUnknown,
  });

  factory Packaging.fromJson(Map<String, dynamic> json) {
    final packagings = json['packagings'] as List? ?? [];

    List<String> materialsList = packagings
        .map((p) => p['material']?.toString() ?? "unknown")
        .toList();

    return Packaging(
      nonRecyclable: json['non_recyclable_and_non_biodegradable_materials'] ??
          0,
      materials: materialsList,
      isUnknown: materialsList.contains("unknown"),
    );
  }
}

