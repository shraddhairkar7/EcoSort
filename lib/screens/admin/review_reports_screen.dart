import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/models/issue_report.dart';
import 'package:ecosort/providers/bin_provider.dart';
import 'package:ecosort/providers/issue_provider.dart';
import 'package:ecosort/theme/app_theme.dart';

class ReviewReportsScreen extends StatelessWidget {
  const ReviewReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<IssueProvider>().reports;
    final bins = context.watch<BinProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Citizen reports')),
      body: reports.isEmpty
          ? const Center(child: Text('No reports yet.'))
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (_, i) {
                final r = reports[i];
                final binName = r.binId.isEmpty
                    ? 'Unlinked'
                    : (bins.byId(r.binId)?.name ?? r.binId);
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: r.photoUrl.startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: r.photoUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.broken_image_outlined),
                            ),
                          )
                        : const Icon(Icons.report_outlined),
                    title: Text('${r.category.label} · $binName'),
                    subtitle: Text(
                      '${r.notes}\n${r.lat.toStringAsFixed(4)}, '
                      '${r.lng.toStringAsFixed(4)}',
                    ),
                    isThreeLine: true,
                    trailing: r.status == IssueStatus.resolved
                        ? const Icon(Icons.check_circle,
                            color: AppColors.fillGreen)
                        : TextButton(
                            onPressed: () =>
                                context.read<IssueProvider>().resolve(r.id),
                            child: const Text('Resolve'),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
