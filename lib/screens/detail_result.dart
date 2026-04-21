import 'package:flutter/material.dart';
import 'package:helloworld/responses/product_response.dart';

class DetailResult extends StatefulWidget {
  final ProductResponse product; // recibe un producto

  const DetailResult({super.key, required this.product}); // Constructor actualizado

  @override
  State<DetailResult> createState() => _DetailResult();
}

class _DetailResult extends State<DetailResult> {

  List<Color> color_eco(String value){
    switch(value.toLowerCase()){
      case 'a': return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
      case 'b': return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)]; // Amarillo
      case 'c': return [const Color(0xFFFFB74D), const Color(0xFFF57C00)]; // Naranja
      case 'd': return [const Color(0xFFE57373), const Color(0xFFD32F2F)]; // Rojo
      case 'e': return [const Color(0xFFBA68C8), const Color(0xFF7B1FA2)]; // Morado
      default: return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
    }
  }

  List<Color> color_nova(String value){
    switch(value){
      case '1': return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
      case '2': return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)]; // Amarillo
      case '3': return [const Color(0xFFFFB74D), const Color(0xFFF57C00)]; // Naranja
      case '4': return [const Color(0xFFE57373), const Color(0xFFD32F2F)]; // Rojo
      default: return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
    }
  }

  List<Color> color_adittives(String value){
    switch(value){
      case '0' || '1': return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
      case '2' || '3': return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)]; // Amarillo
      case '4' : return [const Color(0xFFFFB74D), const Color(0xFFF57C00)]; // Naranja
      default: return [const Color(0xFFE57373), const Color(0xFFD32F2F)];
    }
  }

  List<Color> color_palm_oil(String value){
    switch(value){
      case '0': return [const Color(0xFF86C28B), const Color(0xFF6DA67A)];
      case '1': return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)]; // Amarillo
      case '2' : return [const Color(0xFFFFB74D), const Color(0xFFF57C00)]; // Naranja
      default: return [const Color(0xFFE57373), const Color(0xFFD32F2F)];
    }
  }

  List<Color> color_co2(double value){
    if (value < 2){
      return [const Color(0xFF86C28B), const Color(0xFF6DA67A)]; // Verde
    } else if (value < 5){
      return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)]; // Amarillo
    } else {
      return [const Color(0xFFE57373), const Color(0xFFD32F2F)]; // Rojo
    }
  }

  List<Color> color_non_recyclable(int value) {
    if (value == 0) {
      return [const Color(0xFF86C28B), const Color(0xFF6DA67A)]; // Verde
    } else if (value <= 2) {
      return [const Color(0xFFFFEE58), const Color(0xFFFBC02D)]; // Amarillo
    } else if (value == 3) {
      return [const Color(0xFFFFB74D), const Color(0xFFF57C00)]; // Naranja
    } else {
      return [const Color(0xFFE57373), const Color(0xFFD32F2F)]; // Rojo
    }
  }

  bool isRedMaterial(String m) {
    const red = ['pvc', 'ps', 'polystyrene'];
    return red.any((e) => m.toLowerCase().contains(e));
  }

  TextSpan buildHighlightedMaterials(List<String> materials) {
    List<TextSpan> spans = [];
    for (int i = 0; i < materials.length; i++) {
      final material = materials[i];
      final isLast = i == materials.length - 1;
      
      spans.add(TextSpan(
        text: material + (isLast ? "" : ", "),
        style: TextStyle(
          color: isRedMaterial(material) ? Colors.red : Colors.black,
          fontWeight: isRedMaterial(material) ? FontWeight.bold : FontWeight.normal,
        ),
      ));
    }
    return TextSpan(children: spans);
  }

  TextSpan buildHighlightedIngredients(String text) {
    final keywordsHigh = ['palm oil', 'beef', 'butter'];
    final keywordsMedium = ['milk', 'cocoa', 'coffee'];

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

  double calculateScore() {
    double score = 10.0;

    // EcoScore
    switch (widget.product.ecoscore_grade.toLowerCase()) {
      case 'a': score -= 0; break;
      case 'b': score -= 1; break;
      case 'c': score -= 2; break;
      case 'd': score -= 3; break;
      case 'e': score -= 4; break;
    }

    // CO2
    final co2 = widget.product.agribalyse.co2Total;
    if (co2 > 5) score -= 2;
    else if (co2 > 2) score -= 1;

    // Nova (ultraprocesado)
    if (widget.product.nova_group >= 4) score -= 2;
    else if (widget.product.nova_group == 3) score -= 1;

    // Palm oil
    if (widget.product.palm_oil_count > 0) score -= 1;

    // Additives
    if (widget.product.additives_count > 5) score -= 2;
    else if (widget.product.additives_count > 0) score -= 1;

    // Packaging
    if (widget.product.packaging.nonRecyclable > 2) score -= 1;

    return score.clamp(0, 10);
  }

  Color getScoreColor(double score) {
    if (score >= 7) return const Color(0xFF6DA67A); // Verde
    if (score >= 4) return const Color(0xFFFBC02D); // Amarillo
    return const Color(0xFFE57373); // Rojo
  }


  //Método obligatorio
  @override
  Widget build(BuildContext context) {
    final ecoColors = color_eco(widget.product.ecoscore_grade);
    final novaColors = color_nova(widget.product.nova_group.toString());
    final additiveColors = color_adittives(widget.product.additives_count.toString());
    final palmOilColors = color_palm_oil(widget.product.palm_oil_count.toString());
    final co2Colors = color_co2(widget.product.agribalyse.co2Total);
    final nonRecyclableColors = color_non_recyclable(widget.product.packaging.nonRecyclable);
    final double score = calculateScore();

    return Scaffold(
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.product.image_url.isNotEmpty)
              Image.network(
                widget.product.image_url,
                height: 250,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //nombre del producto
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

                      //Nota del producto
                      Column(
                        children: [
                          Text(
                            score.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: getScoreColor(score),
                            ),
                          ),
                          const Text(
                            '/10',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 40, thickness: 3, color: Color(0xff859987)),
                  _buildInfoRow('Eco-Score', widget.product.ecoscore_grade.toUpperCase(), 
                      customColors: ecoColors),
                  _buildInfoRow('Nova Group', widget.product.nova_group.toString(), customColors: novaColors),
                  _buildInfoRow('Additives', widget.product.additives_count.toString(), customColors: additiveColors),
                  _buildInfoRow('Palm Oil Count', widget.product.palm_oil_count.toString(), customColors: palmOilColors),
                  _buildInfoRow('Total Co2 Emissions', widget.product.agribalyse.co2Total.toString(), customColors: co2Colors),
                  
                  const Divider(height: 40, thickness: 3, color: Color(0xff859987)),
                  const Text(
                    'Packaging Information:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow('Non-recyclable materials', widget.product.packaging.nonRecyclable.toString(), customColors: nonRecyclableColors),
                  const SizedBox(height: 5),
                  const Text('Materials list:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  RichText(
                    text: buildHighlightedMaterials(widget.product.packaging.materials),
                  ),
                  
                  const Divider(height: 40, thickness: 2.5, color: Color(0xff859987)),
                  const Text(
                    'Ingredients:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: buildHighlightedIngredients(widget.product.ingredients_text),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {List<Color>? customColors}) {
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
