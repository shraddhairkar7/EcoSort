import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/providers/bin_provider.dart';
import 'package:ecosort/providers/route_provider.dart';
import 'package:ecosort/theme/app_theme.dart';
import 'package:ecosort/widgets/bin_card.dart';
import 'package:ecosort/widgets/eco_map.dart';
import 'package:ecosort/widgets/empty_state.dart';
import 'package:ecosort/widgets/stat_counter.dart';

/// Collector home: nearest-neighbor tour of bins that are ≥ 80% full.
class TodayRouteScreen extends StatelessWidget {
  const TodayRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bins = context.watch<BinProvider>().bins;
    final rp = context.watch<RouteProvider>();
    final byId = {for (final b in bins) b.id: b};
    final ordered = [
      for (final s in rp.route.stops)
        if (byId[s.binId] != null) byId[s.binId]!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's route"),
        actions: [
          IconButton(
            tooltip: 'Rebuild nearest-neighbor tour',
            onPressed: () => rp.rebuild(bins),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                StatCounter(
                  label: 'Smart route',
                  value: '${rp.route.smartDistanceKm.toStringAsFixed(2)} km',
                  icon: Icons.alt_route,
                  accent: AppColors.primary,
                ),
                const SizedBox(width: 12),
                StatCounter(
                  label: 'Old fixed route',
                  value: '${rp.route.baselineDistanceKm.toStringAsFixed(2)} km',
                  icon: Icons.straighten,
                  accent: AppColors.accent,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                StatCounter(
                  label: 'Fuel (smart)',
                  value: '${rp.fuelSmartL.toStringAsFixed(2)} L',
                  icon: Icons.local_gas_station_outlined,
                ),
                const SizedBox(width: 12),
                StatCounter(
                  label: 'Fuel (baseline)',
                  value: '${rp.fuelBaselineL.toStringAsFixed(2)} L',
                  icon: Icons.local_gas_station,
                  accent: AppColors.accent,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Saved ${rp.route.distanceSavedKm.toStringAsFixed(2)} km by '
              'skipping bins under 80% full and using nearest-neighbor order. '
              '${rp.collectedCount}/${rp.route.stops.length} collected.',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: EcoMap(
              bins: ordered,
              routeBinIds: [for (final s in rp.route.stops) s.binId],
              height: 200,
            ),
          ),
          Expanded(
            child: rp.route.stops.isEmpty
                ? const EmptyState(
                    message: 'No bins ≥ 80% full. No collection needed.',
                    icon: Icons.verified_outlined,
                  )
                : ListView.builder(
                    itemCount: rp.route.stops.length,
                    itemBuilder: (_, i) {
                      final stop = rp.route.stops[i];
                      final bin = byId[stop.binId];
                      if (bin == null) return const SizedBox.shrink();
                      return Dismissible(
                        key: ValueKey(stop.binId),
                        direction: stop.collected
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          color: AppColors.secondary,
                          child: const Text(
                            'Collected',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        onDismissed: (_) => rp.markCollected(stop.binId),
                        child: BinCard(
                          bin: bin,
                          subtitle: 'Stop ${stop.order} · ${bin.zone}',
                          trailing: stop.collected
                              ? const Icon(Icons.check_circle,
                                  color: AppColors.fillGreen)
                              : TextButton(
                                  onPressed: () => rp.markCollected(stop.binId),
                                  child: const Text('Collect'),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
