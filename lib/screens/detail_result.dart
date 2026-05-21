import 'package:flutter/material.dart';
import 'package:helloworld/responses/product_response.dart';
import 'package:translator/translator.dart';

class DetailResult extends StatefulWidget {
  final ProductResponse product; // producto recibido

  const DetailResult({super.key, required this.product});

  @override
  State<DetailResult> createState() => _DetailResult();
}

class _DetailResult extends State<DetailResult> {

  //TRADUCIR INGREDIENTES Y MATERIALES EN CASO DE QUE NO VENNGAN EN INGLÉS
  final translator = GoogleTranslator();

  // ingredientes contaminantes
  final keywordsHigh = ['palm oil', 'beef', 'butter'];
  final keywordsMedium = ['milk', 'cocoa', 'coffee'];

  // materiales contaminantes
  final redMaterials = ['pvc', 'ps', 'polystyrene', 'plastic'];

  String translatedIngredients = "";
  List<String> translatedMaterials = [];

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    //Ingredientes del producto
    String rawIngredients = widget.product.ingredients_text_en.isEmpty
        ? widget.product.ingredients_text
        : widget.product.ingredients_text_en;

    String ingredientsEn = await translateText(rawIngredients);

    // Traducir materiales uno a uno
    List<String> materialsEn = [];
    for (var m in widget.product.packaging.materials) {
      materialsEn.add(await translateText(m));
    }

    if (mounted) {
      setState(() {
        translatedIngredients = ingredientsEn;
        translatedMaterials = materialsEn;
      });
    }
  }

    Future<String> translateText(String text) async {
    if (text.isEmpty || text == "unknown") return text;

    var translation = await translator.translate(text, to: 'en');
    return translation.text;
  }


  // Función que relaciona cada nivel del ecoScore con un color
  List<Color> color_eco(String value) {
    switch (value.toLowerCase()) {
      case 'a':
        return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
      case 'b':
        return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)]; // Amarillo
      case 'c':
        return [const Color(0xFFFFB74D), const Color(0xFFF57C00)]; // Naranja
      case 'd':
        return [const Color(0xFFE57373), const Color(0xFFD32F2F)]; // Rojo
      case 'e':
        return [const Color(0xFFBA68C8), const Color(0xFF7B1FA2)]; // Morado
      case "unknown":
        return [const Color(0xFFC3C3C3), const Color(0xFF7F7F7F)];
      default:
        return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
    }
  }

  // Función que relaciona cada nivel del novaScore con un color
  List<Color> color_nova(String value) {
    switch (value.toLowerCase()) {
      case '1':
        return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
      case '2':
        return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)]; // Amarillo
      case '3':
        return [const Color(0xFFFFB74D), const Color(0xFFF57C00)]; // Naranja
      case '4':
        return [const Color(0xFFE57373), const Color(0xFFD32F2F)]; // Rojo
      case "unknown":
        return [const Color(0xFFC3C3C3), const Color(0xFF7F7F7F)];
      default:
        return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
    }
  }

  // Función que relaciona el número de aditivos con un color
  List<Color> color_adittives(String value) {
    switch (value.toLowerCase()) {
      case '0' || '1':
        return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
      case '2' || '3':
        return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)]; // Amarillo
      case '4':
        return [const Color(0xFFFFB74D), const Color(0xFFF57C00)]; // Naranja
      case "unknown":
        return [const Color(0xFFC3C3C3), const Color(0xFF7F7F7F)];
      default:
        return [const Color(0xFFE57373), const Color(0xFFD32F2F)];
    }
  }

  // Función que relaciona el número de ingredientes con aceite de palma con un color
  List<Color> color_palm_oil(String value) {
    switch (value.toLowerCase()) {
      case '0':
        return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
      case '1':
        return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)]; // Amarillo
      case '2':
        return [const Color(0xFFFFB74D), const Color(0xFFF57C00)]; // Naranja
      case "unknown":
        return [const Color(0xFFC3C3C3), const Color(0xFF7F7F7F)];
      default:
        return [const Color(0xFFE57373), const Color(0xFFD32F2F)];
    }
  }

  // Función que relaciona la cantidad de co2 producido con un color
  List<Color> color_co2(String value) {
    //Manejar el caso de desconocido
    if (value.toLowerCase() == "unknown") {
      return [const Color(0xFFC3C3C3), const Color(0xFF7F7F7F)];
    }

    //Convertir a número
    final double? co2Value = double.tryParse(value);

    if (co2Value == null) {
      return [const Color(0xFFE57373), const Color(0xFFD32F2F)];
    }

    if (co2Value < 3.0) {
      // De 0 a 2.99
      return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
    } else if (co2Value < 6.0) {
      // De 3 a 5.99
      return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)];
    } else {
      // 6 o más
      return [const Color(0xFFE57373), const Color(0xFFD32F2F)];
    }
  }

  // Función que relaciona el número de materiales no reciclables con un color
  List<Color> color_non_recyclable(String value) {
    switch (value.toLowerCase()) {
      case '0':
        return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
      case '1' || '2':
        return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)];
      case '3':
        return [const Color(0xFFFFB74D), const Color(0xFFF57C00)];
      case "unknown":
        return [const Color(0xFFC3C3C3), const Color(0xFF7F7F7F)];
      default:
        return [const Color(0xFFE57373), const Color(0xFFD32F2F)];
    }
  }

  // Función que verifica si un material es contaminante
  bool isRedMaterial(String m) {
    return redMaterials.any((e) => m.toLowerCase().contains(e));
  }

  // Función que verifica los materiales son contaminantes
  TextSpan buildHighlightedMaterials(List<String> materials) {
    List<TextSpan> spans = [];
    for (int i = 0; i < materials.length; i++) {
      final material = materials[i];
      final isLast = i == materials.length - 1;

      spans.add(TextSpan(
        text: material + (isLast ? "" : ", "),
        style: TextStyle(
          color: isRedMaterial(material) ? Colors.red : Colors.black,
          fontWeight:
              isRedMaterial(material) ? FontWeight.bold : FontWeight.normal,
        ),
      ));
    }
    return TextSpan(children: spans);
  }

  // Función que verifica si los ingredientes son contaminante
  TextSpan buildHighlightedIngredients(String text) {
    List<TextSpan> spans = [];

    for (var word in text.split(' ')) {
      final lower = word.toLowerCase();

      if (keywordsHigh.any((k) => lower.contains(k))) {
        spans.add(TextSpan(
          text: '$word ',
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ));
      } else if (keywordsMedium.any((k) => lower.contains(k))) {
        spans.add(TextSpan(
          text: '$word ',
          style: const TextStyle(color: Colors.orange),
        ));
      } else {
        spans.add(TextSpan(
          text: '$word ',
          style: const TextStyle(color: Colors.black),
        ));
      }
    }

    return TextSpan(children: spans);
  }

  // Función que identifica cada impato medioambiental con un color
  Color getScoreColor(double score, bool isScoreValid) {
    if (!isScoreValid) {
      return const Color(0xFFC3C3C3); // Gris
    }
    if (score >= 7) return const Color(0xFF6DA67A); // Verde
    if (score >= 4) return const Color(0xFFFBC02D); // Amarillo
    return const Color(0xFFE57373); // Rojo
  }

  @override
  Widget build(BuildContext context) {
    // Inicializar la información del porducto extraída de la respuesta de la API y la asignación de colores

    //ecoScore
    String ecoScore;
    if (widget.product.ecoscore_grade == "-1" || widget.product.ecoscore_grade == "") {
      ecoScore = "UNKNOWN";
    } else {
      ecoScore = widget.product.ecoscore_grade;
    }
    final ecoColors = color_eco(ecoScore);

    //novaScore
    String novaScore;
    if (widget.product.nova_group == -1) {
      novaScore = "UNKNOWN";
    } else {
      novaScore = widget.product.nova_group.toString();
    }
    final novaColors = color_nova(novaScore);

    //aditiveScore
    String additiveScore;
    if (widget.product.additives_count == -1) {
      additiveScore = "UNKNOWN";
    } else {
      additiveScore = widget.product.additives_count.toString();
    }
    final additiveColors = color_adittives(additiveScore);

    //palmOilScore
    String palmOilScore;
    if (widget.product.palm_oil_count == -1) {
      palmOilScore = "UNKNOWN";
    } else {
      palmOilScore = widget.product.palm_oil_count.toString();
    }
    final palmOilColors = color_palm_oil(palmOilScore);

    //co2Score
    String co2Score;
    if (widget.product.agribalyse.co2Total == -1) {
      co2Score = "UNKNOWN";
    } else {
      co2Score = widget.product.agribalyse.co2Total.toString();
    }
    final co2Color = color_co2(co2Score);

    //nonRecyclableScore
    String nonRecyclableScore;
    if (widget.product.packaging.nonRecyclable == -1) {
      nonRecyclableScore = "UNKNOWN";
    } else {
      nonRecyclableScore = widget.product.packaging.nonRecyclable.toString();
    }
    final nonRecyclableColors = color_non_recyclable(nonRecyclableScore);

    final double score = widget.product.calculateTotalScore();
    final bool isScoreValid = score != -1; //-1 significa sin datos suficientes

    return Scaffold(
      //Barra superior
      appBar: AppBar(
        toolbarHeight: 60,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF86C28B),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          'EcoLens Analysis',
          style: TextStyle(
            color: Color(0xFF6DA67A),
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
      ),

      //Scroll view para poder visualizar todos los productos
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Imagen
            if (widget.product.image_url.isNotEmpty)
              Image.network(
                widget.product.image_url,
                height: 250,
                fit: BoxFit.contain,
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    // nombre del producto
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name_es.isNotEmpty
                              ? widget.product.name_es
                              : widget.product.name_en,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Nota del producto
                      Column(
                        children: [
                          Text(
                            isScoreValid ? score.toStringAsFixed(1) : "N/A",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: getScoreColor(score, isScoreValid),
                            ),
                          ),
                          Text(
                            isScoreValid ? '/10' : '',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(height: 40, thickness: 3, color: Color(0xff859987)),

                  //Información adicional del producto
                  _buildInfoRow('Eco-Score', ecoScore.toUpperCase(),
                      customColors: ecoColors),
                  _buildInfoRow('Nova Group', novaScore, customColors: novaColors),
                  _buildInfoRow('Additives', additiveScore, customColors: additiveColors),
                  _buildInfoRow('Palm Oil Count', palmOilScore, customColors: palmOilColors),
                  _buildInfoRow('Total Co2 Emissions', co2Score, customColors: co2Color),

                  const Divider(height: 40, thickness: 3, color: Color(0xff859987)),

                  //Información sobre el embalaje
                  const Text(
                    'Packaging Information:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow('Non-recyclable materials',
                      nonRecyclableScore, customColors: nonRecyclableColors),
                  const SizedBox(height: 5),

                  const Text('Materials list:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  RichText(
                    text: buildHighlightedMaterials(
                      translatedMaterials.isEmpty ? widget.product.packaging.materials : translatedMaterials,
                    ),
                  ),
                  const Divider(height: 40, thickness: 2.5, color: Color(0xff859987)),

                  //Información sobre los ingredinetes
                  const Text(
                    'Ingredients:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: buildHighlightedIngredients(
                        translatedIngredients.isEmpty ? widget.product.ingredients_text : translatedIngredients
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {List<Color>? customColors}) {
    //Colores previamente calculados
    final bgColor = customColors != null ? customColors[0].withOpacity(0.2) : const Color(0xFF86C28B).withOpacity(0.2);
    final textColor = customColors != null ? customColors[1] : const Color(0xFF6DA67A);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}