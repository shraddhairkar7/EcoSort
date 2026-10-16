import 'package:flutter/foundation.dart';

import 'package:ecosort/config/app_config.dart';
import 'package:ecosort/models/bin.dart';
import 'package:ecosort/models/route_stop.dart';
import 'package:ecosort/utils/route_optimizer.dart';

/// Rebuilds the collector's tour whenever bin fill-levels change.
class RouteProvider extends ChangeNotifier {
  RouteProvider({RouteOptimizer optimizer = const RouteOptimizer()})
      : _optimizer = optimizer;

  final RouteOptimizer _optimizer;
  CollectionRoute route = const CollectionRoute(
    stops: [],
    smartDistanceKm: 0,
    baselineDistanceKm: 0,
  );

  void rebuild(List<Bin> bins) {
    route = _optimizer.buildTodayRoute(bins);
    notifyListeners();
  }

  void markCollected(String binId) {
    route = CollectionRoute(
      stops: [
        for (final s in route.stops)
          if (s.binId == binId) s.copyWith(collected: true) else s,
      ],
      smartDistanceKm: route.smartDistanceKm,
      baselineDistanceKm: route.baselineDistanceKm,
    );
    notifyListeners();
  }

  int get collectedCount => route.stops.where((s) => s.collected).length;

  double get fuelSmartL => route.smartDistanceKm * AppConfig.litresPerKm;
  double get fuelBaselineL => route.baselineDistanceKm * AppConfig.litresPerKm;
}
