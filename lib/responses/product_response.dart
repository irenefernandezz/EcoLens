//Clase que recoge los datos de la API de EcoScore
class ProductResponse {

  String name_en;
  String name_es;
  String brand;
  String image_url;
  int additives_count;
  int palm_oil_count;
  String ingredients_text;
  String ecoscore_grade;
  int nova_group; //grado de procesamiento
  String ingredients_text_en;


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
   required this.ingredients_text_en,
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
      //Si no hay datos, los valores numéricos se mapean como -1
      nova_group: product['nova_group'] ?? -1,
      additives_count: product['additives_n'] ?? -1,
      palm_oil_count: product['ingredients_from_or_that_may_be_from_palm_oil_n'] ?? -1,
      ingredients_text: product['ingredients_text'] ?? "",
      ingredients_text_en: product['ingredients_text_en'] ?? "",
      ecoscore_grade: product['ecoscore_grade'] ?? "",


      agribalyse: Agribalyse.fromJson(agribalyseData),
      packaging: Packaging.fromJson(product),
    );
  }

  int hasnoData(){
    var resul = 0;
    if(ecoscore_grade.isEmpty) resul++;
    if(agribalyse.co2Total == -1) resul++;
    if(nova_group == -1) resul++;
    if(ingredients_text.isEmpty && ingredients_text_en.isEmpty) resul++;
    if(additives_count == -1) resul++;
    if(palm_oil_count == -1) resul++;
    return resul;

  }

  double calculateTotalScore() {

    //Si hay dos datos o más sin información la nota no es válida
    if (hasnoData() >= 2) {
      return -1.0;
    }

    double score = 10.0;

    //ECOSCORE
    switch (ecoscore_grade.toLowerCase()) {
      case 'a': score -= 0; break;
      case 'b': score -= 1; break;
      case 'c': score -= 2; break;
      case 'd': score -= 3; break;
      case 'e': score -= 4; break;
    }

    //CO2 EMISSIONS
    if (agribalyse.co2Total != -1) {
      if (agribalyse.co2Total > 5) score -= 2;
      else if (agribalyse.co2Total > 2) score -= 1;
    }

    //NOVA GROUP
    if (nova_group != -1) {
      if (nova_group >= 4) score -= 2;
      else if (nova_group == 3) score -= 1;
    }

    //PALM OIL & ADDITIVES
    if (palm_oil_count > 0) score -= 1;
    if (additives_count != -1) {
      if (additives_count > 5) score -= 2;
      else if (additives_count > 0) score -= 1;
    }

    //PACKAGING IMPACT
    if (packaging.nonRecyclable > 2) score -= 1;

    //INGREDIENTES (Usar la versión en inglés si existe)
    final keywordsHigh = ['palm oil', 'beef', 'butter', 'carne', 'mantequilla'];
    final keywordsMedium = ['milk', 'cocoa', 'coffee', 'leche', 'cacao', 'café'];


    String textToSearch = (ingredients_text_en.isNotEmpty
        ? ingredients_text_en
        : ingredients_text)
        .toLowerCase();

    for (var kw in keywordsHigh) {
      if (textToSearch.contains(kw)) score -= 0.5;
    }
    for (var kw in keywordsMedium) {
      if (textToSearch.contains(kw)) score -= 0.3;
    }

    //MATERIALES
    final redMaterials = ['pvc', 'ps', 'polystyrene', 'plastic', 'plástico'];
    for (var material in packaging.materials) {
      String m = material.toLowerCase();
      if (redMaterials.any((rm) => m.contains(rm))) {
        score -= 0.5;
      }
    }

    return score.clamp(0.0, 10.0);
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
          -1,
      materials: materialsList,
      isUnknown: materialsList.contains("unknown"),
    );
  }
}
