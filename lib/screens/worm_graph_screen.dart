import 'package:cricket_scorer/models/match.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WormGraphScreen extends StatelessWidget {
  final Match match;

  const WormGraphScreen({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<FlSpot> innings1Spots = [];
    int innings1Runs = 0;
    for (int i = 0; i < match.innings1.overs.length; i++) {
      innings1Runs += match.innings1.overs[i].runs;
      innings1Spots.add(FlSpot(i.toDouble(), innings1Runs.toDouble()));
    }

    List<FlSpot> innings2Spots = [];
    int innings2Runs = 0;
    for (int i = 0; i < match.innings2.overs.length; i++) {
      innings2Runs += match.innings2.overs[i].runs;
      innings2Spots.add(FlSpot(i.toDouble(), innings2Runs.toDouble()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Worm Graph'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: true)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1)),
            lineBarsData: [
              LineChartBarData(
                spots: innings1Spots,
                isCurved: true,
                color: Colors.blue,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: innings2Spots,
                isCurved: true,
                color: Colors.red,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
