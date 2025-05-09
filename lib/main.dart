import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Painel de Monitoramento',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic>? dados;
  String? ultimaAtualizacao;
  Timer? _timer;
  List<dynamic> historico = [];

  @override
  void initState() {
    super.initState();
    fetchDados();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => fetchDados());
  }

  Future<void> fetchDados() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.3.162:8000/dados'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Ordenar do mais antigo para o mais recente

        setState(() {
          dados = jsonData.last; // Último dado para exibição principal
          historico = jsonData.length > 10
              ? jsonData.sublist(jsonData.length - 10)
              : jsonData;
          ultimaAtualizacao = TimeOfDay.now().format(context);
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar dados: $e');
    }
  }

  Color getButtonColor(String estado) {
    return estado == 'pressionado' ? Colors.green : Colors.red;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Painel de Monitoramento'),
        backgroundColor: const Color.fromARGB(255, 104, 177, 179),
      ),
      body: dados == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  /// TEMPERATURA
                  Card(
                    color: dados!['temperatura'] > 30
                        ? Colors.red[100]
                        : dados!['temperatura'] < 15
                            ? Colors.blue[100]
                            : Colors.yellow[100],
                    child: ListTile(
                      title: const Text('🌡️ Temperatura'),
                      subtitle: Text('${dados!['temperatura']} °C'),
                    ),
                  ),

                  /// JOYSTICK
                  Card(
                    child: Column(
                      children: [
                        const ListTile(title: Text('🧭 Roda dos Ventos')),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('🅧: ${dados!['joystick']['x']}'),
                            Text('🅨: ${dados!['joystick']['y']}'),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Direção: ${dados!['joystick']['direcao']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// BOTÕES
                  Card(
                    child: Column(
                      children: [
                        const ListTile(title: Text('🔘 Botões')),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                color: getButtonColor(dados!['botao1']),
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  dados!['botao1'] == 'pressionado'
                                      ? '🔘 Botão 1 ON'
                                      : '🔘 Botão 1 OFF',
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                color: getButtonColor(dados!['botao2']),
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  dados!['botao2'] == 'pressionado'
                                      ? '🔘 Botão 2 ON'
                                      : '🔘 Botão 2 OFF',
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// GRÁFICO DE TEMPERATURA
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Column(
                      children: [
                        const ListTile(
                          title: Text(
                            '📈 Temperatura (últimos 2 dias)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 300,
                            child: LineChart(LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: (historico.length / 5)
                                        .floorToDouble(), // mostra menos labels
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= historico.length) {
                                        return const Text('');
                                      }
                                      final dado = historico[index];
                                      final dataHora =
                                          DateTime.parse(dado['criado_em']);
                                      return Text(
                                        '${dataHora.hour}:${dataHora.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 5,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toStringAsFixed(0),
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: const Border(
                                  bottom: BorderSide(),
                                  left: BorderSide(),
                                ),
                              ),
                              lineTouchData: LineTouchData(
                                handleBuiltInTouches: true,
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipRoundedRadius: 8,
                                  tooltipPadding: const EdgeInsets.all(8),
                                  fitInsideHorizontally: true,
                                  fitInsideVertically: true,
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      final index = spot.x.toInt();
                                      if (index < 0 ||
                                          index >= historico.length)
                                        return null;

                                      final dado = historico[index];
                                      final dataHora =
                                          DateTime.parse(dado['criado_em']);
                                      final temperatura =
                                          dado['temperatura'].toDouble();

                                      return LineTooltipItem(
                                        '🕒 ${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}\n'
                                        '🌡️ ${temperatura.toStringAsFixed(1)} °C',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  curveSmoothness: 0.3,
                                  spots:
                                      List.generate(historico.length, (index) {
                                    final temperatura = historico[index]
                                            ['temperatura']
                                        .toDouble();
                                    return FlSpot(
                                        index.toDouble(), temperatura);
                                  }),
                                  dotData: FlDotData(show: false),
                                  barWidth: 3,
                                  color: const Color(0xFF0B8678),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF0B8678)
                                            .withOpacity(0.3),
                                        const Color(0xFF0B8678)
                                            .withOpacity(0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// HORA DA ÚLTIMA ATUALIZAÇÃO
                  if (ultimaAtualizacao != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        '⏱️ Atualizado às $ultimaAtualizacao',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
