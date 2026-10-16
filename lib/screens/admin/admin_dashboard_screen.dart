import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/models/bin.dart';
import 'package:ecosort/providers/bin_provider.dart';
import 'package:ecosort/theme/app_theme.dart';
import 'package:ecosort/widgets/eco_map.dart';
import 'package:ecosort/widgets/fill_level_badge.dart';
import 'package:ecosort/widgets/stat_counter.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bins = context.watch<BinProvider>().bins;
    final critical = bins.where((b) => b.isCritical).length;
    final avg = bins.isEmpty
        ? 0.0
        : bins.fold<int>(0, (p, b) => p + b.fillLevelPercent) / bins.length;

    return Scaffold(
      appBar: AppBar(title: const Text('City dashboard')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                StatCounter(
                  label: 'Bins',
                  value: '${bins.length}',
                  icon: Icons.delete_outline,
                ),
                const SizedBox(width: 12),
                StatCounter(
                  label: 'Critical',
                  value: '$critical',
                  icon: Icons.warning_amber,
                  accent: AppColors.fillRed,
                ),
                const SizedBox(width: 12),
                StatCounter(
                  label: 'Avg fill',
                  value: '${avg.toStringAsFixed(0)}%',
                  icon: Icons.water_drop_outlined,
                  accent: AppColors.accent,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: EcoMap(
              bins: bins,
              height: 320,
              onBinTap: (b) => _details(context, b),
            ),
          ),
          const SizedBox(height: 12),
          for (final b in bins)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: FillLevelBadge.colorFor(b.fillLevelPercent),
                radius: 8,
              ),
              title: Text(b.name),
              subtitle: Text(b.zone),
              trailing: FillLevelBadge(percent: b.fillLevelPercent, compact: true),
              onTap: () => _details(context, b),
            ),
        ],
      ),
    );
  }

  void _details(BuildContext context, Bin bin) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(bin.name),
        content: Text(
          '${bin.zone}\n${bin.type.label}\nFill ${bin.fillLevelPercent}%\n'
          '${bin.lat.toStringAsFixed(4)}, ${bin.lng.toStringAsFixed(4)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
