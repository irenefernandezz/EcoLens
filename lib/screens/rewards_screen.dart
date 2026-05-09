import 'package:flutter/material.dart';
import 'package:helloworld/models/product.dart';
import 'package:helloworld/services/history_service.dart';
import 'package:helloworld/services/user_service.dart';
import 'package:helloworld/models/user.dart' as model;
import 'package:fl_chart/fl_chart.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final HistoryService _historyService = HistoryService();
  final UserService _userService = UserService();
  model.User? currentUser;

  // Colores definidos
  final Color colorGreen = const Color(0xFF86C28B);
  final Color colorYellow = const Color(0xFFFFEE58);
  final Color colorRed = const Color(0xFFE57373);
  final Color colorGrey = Colors.grey;

  //Función para obtener el color según la nota
  Color _getScoreColor(double score) {
    if (score == -1) return colorGrey;
    if (score >= 7) return colorGreen;
    if (score >= 4) return colorYellow;
    return colorRed;
  }

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final user = await _userService.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rewards & Summary',
          style: TextStyle(
            color: Color(0xFF6DA67A),
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<List<Product>>>(
        future: Future.wait([
          _historyService.getProductsByUser(user.id!),
          _historyService.getAllScannedProducts(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading your history'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data found'));
          }

          final userProducts = snapshot.data![0];
          final allScannedProducts = snapshot.data![1];
          final lastProducts = userProducts.take(5).toList();

          //Lógica para el gráfico de tendencia
          //Lógica para el gráfico de tendencia
          final trendProducts = userProducts
              .where((p) => p.score != -1).take(30).toList().reversed.toList();

          List<FlSpot> spots = [];
          for (int i = 0; i < trendProducts.length; i++) {
            spots.add(FlSpot(i.toDouble(), trendProducts[i].score));
          }

          // Cálculos Usuario
          double userTotalScore = 0;
          int userNumProductsWithScore = 0;
          int greenCount = 0;
          int yellowCount = 0;
          int redCount = 0;
          int greyCount = 0;

          for (var product in userProducts) {
            if (product.score == -1) {
              greyCount++;
            } else {
              userTotalScore += product.score;
              userNumProductsWithScore++;
              if (product.score >= 7) {
                greenCount++;
              } else if (product.score >= 4) {
                yellowCount++;
              } else {
                redCount++;
              }
            }
          }

          double userAvgScore =
              userNumProductsWithScore > 0 ? userTotalScore / userNumProductsWithScore : 0;

          // Cálculo Nota Global
          double globalTotalScore = 0;
          int globalNumProductsWithScore = 0;

          for (var product in allScannedProducts) {
            if (product.score != -1) {
              globalTotalScore += product.score;
              globalNumProductsWithScore++;
            }
          }

          double globalAvgScore =
              globalNumProductsWithScore > 0 ? globalTotalScore / globalNumProductsWithScore : 0;

          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Tarjeta de puntuación media usuario
                  Container(
                    width: 350,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6DA67A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Average Eco-Score',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          userAvgScore.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                        //Nota global
                        const Text(
                          'Global Average Eco-Score',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          globalAvgScore.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                            userAvgScore < globalAvgScore ? 'Continue improving your habits!' : 'Keep up the good work!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 30),

                  // Gráfico de Tendencia
                  if (trendProducts.length >= 2)
                    Container(
                      width: 350,
                      height: 250,
                      padding: const EdgeInsets.fromLTRB(10, 20, 25, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Eco-Score Trend',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  //No se muestran los datos ni de arriba, ni de la derecha, ni de abajo
                                  bottomTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  //Valores del 0 al 10
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Text(value.toInt().toString(),
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14));
                                      },
                                    ),
                                  ),
                                ),
                                minX: 0,
                                maxX: spots.isEmpty ? 0 : (spots.length - 1).toDouble(),
                                minY: 0,
                                maxY: 10,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    isCurved: true,
                                    color: const Color(0xFF6DA67A),
                                    barWidth: 3,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: _getScoreColor(spot.y),
                                          strokeWidth: 1,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                    //Área de debajo de la línea
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: const Color(0xFF6DA67A)
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),

                  //Gráfico de quesito
                  if (userProducts.isNotEmpty)
                    Container(
                      width: 350,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Score Distribution',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: [
                                  if (greenCount > 0)
                                    PieChartSectionData(
                                      color: colorGreen,
                                      value: greenCount.toDouble(),
                                      title: '$greenCount',
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  if (yellowCount > 0)
                                    PieChartSectionData(
                                      color: colorYellow,
                                      value: yellowCount.toDouble(),
                                      title: '$yellowCount',
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                  if (redCount > 0)
                                    PieChartSectionData(
                                      color: colorRed,
                                      value: redCount.toDouble(),
                                      title: '$redCount',
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  if (greyCount > 0)
                                    PieChartSectionData(
                                      color: colorGrey,
                                      value: greyCount.toDouble(),
                                      title: '$greyCount',
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          //Leyenda
                          Wrap(
                            spacing: 15,
                            runSpacing: 5,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildLegendItem('Good', colorGreen),
                              _buildLegendItem('Medium', colorYellow),
                              _buildLegendItem('Bad', colorRed),
                              _buildLegendItem('Unknown', colorGrey),
                            ],
                          )
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Resumen de los últimos 5 productos escaneados
                  Container(
                    width: 350,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Last Scans',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: lastProducts.isEmpty
                              ? [const Text("You haven't scanned anything yet")]
                              : lastProducts.map((product) {
                                  return Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                        color: _getScoreColor(product.score),
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Text(
                                        product.score == -1
                                            ? '?'
                                            : product.score.toStringAsFixed(1),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
