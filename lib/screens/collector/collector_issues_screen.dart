import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/models/issue_report.dart';
import 'package:ecosort/providers/bin_provider.dart';
import 'package:ecosort/providers/issue_provider.dart';
import 'package:ecosort/providers/route_provider.dart';
import 'package:ecosort/theme/app_theme.dart';

/// Citizen reports that sit on (or near) today's critical-bin route.
class CollectorIssuesScreen extends StatelessWidget {
  const CollectorIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routeIds = {
      for (final s in context.watch<RouteProvider>().route.stops) s.binId,
    };
    final issues = context.watch<IssueProvider>().openNearBins(routeIds);
    final bins = context.watch<BinProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Issues on today's route")),
      body: issues.isEmpty
          ? const Center(child: Text('No open issues for this route.'))
          : ListView.builder(
              itemCount: issues.length,
              itemBuilder: (_, i) {
                final r = issues[i];
                final binName = r.binId.isEmpty
                    ? 'Not tied to a bin'
                    : (bins.byId(r.binId)?.name ?? r.binId);
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.flag, color: AppColors.accent),
                    title: Text(r.category.label),
                    subtitle: Text(
                      '$binName\n${r.notes}\n${r.timestamp}',
                    ),
                    isThreeLine: true,
                    trailing: r.status == IssueStatus.open
                        ? const Chip(label: Text('Open'))
                        : const Chip(label: Text('Resolved')),
                  ),
                );
              },
            ),
    );
  }
}
