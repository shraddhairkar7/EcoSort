import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/providers/auth_provider.dart';
import 'package:ecosort/providers/impact_provider.dart';
import 'package:ecosort/theme/app_theme.dart';
import 'package:ecosort/widgets/stat_counter.dart';

class MyImpactScreen extends StatelessWidget {
  const MyImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().currentUser;
    final impact = context.watch<ImpactProvider>();
    final board = impact.leaderboard;
    final co2 = impact.kgCo2Saved;

    return Scaffold(
      appBar: AppBar(title: const Text('My impact')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                StatCounter(
                  label: 'Your score',
                  value: '${me?.segregationScore ?? 0}',
                  icon: Icons.stars,
                  accent: AppColors.accent,
                ),
                const SizedBox(width: 12),
                StatCounter(
                  label: 'CO₂ saved (system)',
                  value: '${co2.toStringAsFixed(1)} kg',
                  icon: Icons.cloud_outlined,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'CO₂ is estimated from fewer collection kilometres '
              '(empty bins skipped) × diesel factors in AppConfig. '
              'It is a demo figure, not a lab measurement.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Campus leaderboard',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          for (var i = 0; i < board.length; i++)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: i == 0 ? AppColors.accent : AppColors.secondary,
                child: Text('${i + 1}',
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(board[i].name),
              subtitle: Text(board[i].role.name),
              trailing: Text(
                '${board[i].segregationScore} pts',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              tileColor: board[i].id == me?.id
                  ? AppColors.secondary.withValues(alpha: 0.15)
                  : null,
            ),
        ],
      ),
    );
  }
}
