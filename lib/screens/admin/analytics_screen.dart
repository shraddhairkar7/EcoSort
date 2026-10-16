import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/models/analytics.dart';
import 'package:ecosort/providers/bin_provider.dart';
import 'package:ecosort/providers/impact_provider.dart';
import 'package:ecosort/theme/app_theme.dart';
import 'package:ecosort/widgets/section_header.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<ImpactProvider>().stats;
    final bins = context.watch<BinProvider>().bins;
    final zones = <String, List<int>>{};
    for (final b in bins) {
      zones.putIfAbsent(b.zone, () => []).add(b.fillLevelPercent);
    }
    final zoneAvgs = [
      for (final e in zones.entries)
        ZoneFillStat(
          zone: e.key,
          avgFillPercent: e.value.reduce((a, b) => a + b) / e.value.length,
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        children: [
          const SectionHeader('Collections over the last 14 days'),
          SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LineChart(_collectionsChart(stats)),
            ),
          ),
          const SectionHeader('Trips saved vs baseline'),
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BarChart(_tripsChart(stats)),
            ),
          ),
          const SectionHeader('Average fill by zone (live bins)'),
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BarChart(_zoneChart(zoneAvgs)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  LineChartData _collectionsChart(List<DailyCollectionStat> stats) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 28),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 3,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= stats.length) return const SizedBox.shrink();
              return Text('${stats[i].day.day}',
                  style: const TextStyle(fontSize: 10));
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          spots: [
            for (var i = 0; i < stats.length; i++)
              FlSpot(i.toDouble(), stats[i].collections.toDouble()),
          ],
        ),
      ],
    );
  }

  BarChartData _tripsChart(List<DailyCollectionStat> stats) {
    return BarChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: [
        for (var i = 0; i < stats.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: stats[i].tripsSaved.toDouble(),
                color: AppColors.accent,
                width: 8,
              ),
            ],
          ),
      ],
    );
  }

  BarChartData _zoneChart(List<ZoneFillStat> zones) {
    return BarChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= zones.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  zones[i].zone.replaceAll('Campus ', ''),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: [
        for (var i = 0; i < zones.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: zones[i].avgFillPercent,
                color: AppColors.secondary,
                width: 22,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
      ],
    );
  }
}
