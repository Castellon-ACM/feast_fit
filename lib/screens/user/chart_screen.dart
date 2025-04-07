import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast_fit/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  bool isBarChart = true;

  final List<Color> gradientColors = [
    const Color(0xffc08f66),
    const Color(0xffa2674b),
    const Color(0xff8b4f32),
  ];

  List<FlSpot> chartData = [];
  final TextEditingController _controllerValue = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  void toggleChartType() {
    setState(() {
      isBarChart = !isBarChart;
    });
  }

  List<FlSpot> offsetDuplicatePoints(List<FlSpot> data) {
    List<FlSpot> result = [];
    Map<double, double> seenYValues = {};
    for (var spot in data) {
      if (seenYValues.containsKey(spot.y)) {
        seenYValues[spot.y] = seenYValues[spot.y]! + 1;
      } else {
        seenYValues[spot.y] = spot.x;
      }
      result.add(FlSpot(seenYValues[spot.y]!, spot.y));
    }
    return result;
  }

  Future<void> _loadChartData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();

      final List<dynamic> loadedData = snapshot.get('chartData') ?? [];
      final String weightString = snapshot.get('weight') ?? "0";
      final double initialWeight = double.tryParse(weightString) ?? 0.0;

      setState(() {
        chartData =
            loadedData.map((data) => FlSpot(data['x'], data['y'])).toList();

        if (chartData.isEmpty && initialWeight > 0) {
          chartData.add(FlSpot(
            DateTime.now().millisecondsSinceEpoch.toDouble(),
            initialWeight,
          ));
        }

        chartData = offsetDuplicatePoints(chartData);
      });
    }
  }

  Future<void> addData() async {
    final double value = double.tryParse(_controllerValue.text) ?? 0;

    if (value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El valor debe ser mayor que 0")),
      );
      return;
    }

    if (chartData.isNotEmpty && chartData.last.y == value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Este valor ya fue agregado previamente")),
      );
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isDataAddedToday = chartData.any((spot) {
      final spotDate = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
      return spotDate.year == today.year &&
          spotDate.month == today.month &&
          spotDate.day == today.day;
    });

    if (isDataAddedToday) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Límite de datos alcanzado'),
            content: Text('Solo puedes agregar un dato al día.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final FlSpot newSpot =
        FlSpot(now.millisecondsSinceEpoch.toDouble(), value);
    setState(() {
      chartData.add(newSpot);
      chartData = offsetDuplicatePoints(chartData);
    });

    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'chartData':
            chartData.map((spot) => {'x': spot.x, 'y': spot.y}).toList(),
        'weight': value.toString(),
      });
    }

    _controllerValue.clear();
  }

  Future<void> removeLastData() async {
    if (chartData.isNotEmpty) {
      setState(() {
        chartData.removeLast();
        chartData = offsetDuplicatePoints(chartData);
      });

      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'chartData':
              chartData.map((spot) => {'x': spot.x, 'y': spot.y}).toList(),
        });
      }
    }
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: chartData.asMap().entries.map((entry) {
          int index = entry.key;
          FlSpot spot = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: spot.y,
                width: 20,
                gradient: LinearGradient(
                  colors: [
                    gradientColors[index % gradientColors.length],
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                return Text(index < chartData.length ? '${index + 1}º' : '');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            gradient: LinearGradient(colors: gradientColors),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                return Text(index < chartData.length ? '${index + 1}º' : '');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const CustomAppBar2(title: 'Gráficos'),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Visualiza tus datos en diferentes formatos.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controllerValue,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addData,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: gradientColors.first,
                  ),
                  child: const Text('Agregar Datos'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed:
                      chartData.length >= 2 && isBarChart ? removeLastData : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: gradientColors.first,
                  ),
                  child: const Text('Eliminar Último Dato'),
                ),
                const SizedBox(height: 60),
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: isBarChart ? _buildBarChart() : _buildLineChart(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: chartData.length >= 2 ? toggleChartType : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: gradientColors.first,
                  ),
                  child: Text(isBarChart
                      ? 'Cambiar a Gráfico de Líneas'
                      : 'Cambiar a Gráfico de Barras'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
