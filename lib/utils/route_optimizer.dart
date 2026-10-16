import 'package:ecosort/config/app_config.dart';
import 'package:ecosort/models/bin.dart';
import 'package:ecosort/models/route_stop.dart';
import 'package:ecosort/utils/geo_utils.dart';

/// Builds today's collection route with a **nearest-neighbor** heuristic.
///
/// # Why nearest-neighbor (and not "the perfect route")?
/// Visiting a set of bins and returning to the depot is a Travelling
/// Salesman Problem (TSP). Exact TSP is NP-hard — the number of possible
/// tours is n! which explodes after ~10 stops. For a college demo with
/// ~15 bins we want something you can:
///   1. implement in ~40 lines,
///   2. dry-run on paper,
///   3. defend in a viva ("greedy, O(n²), good enough").
///
/// # Algorithm (greedy)
///   START at the depot (college gate).
///   WHILE unvisited bins remain:
///     pick the unvisited bin closest to where we currently are
///     append it to the tour
///     move "current location" to that bin
///   END
///   (We also measure the trip back to the depot for fuel numbers.)
///
/// # Complexity
///   Each of the n steps scans up to n remaining bins → O(n²) time,
///   O(n) extra memory. Fine for hundreds of bins; for a whole city
///   you'd swap this file for a proper VRP solver.
///
/// # What we compare against
///   [baselineDistanceKm] walks EVERY bin in a fixed zone-by-zone order
///   (the "old truck route" that does not look at fill sensors). The
///   smart route only visits bins with fill >= [AppConfig.criticalFillPercent].
///   Distance saved ≈ fewer stops + a better visit order.
class RouteOptimizer {
  const RouteOptimizer();

  CollectionRoute buildTodayRoute(List<Bin> allBins) {
    final critical =
        allBins.where((b) => b.fillLevelPercent >= AppConfig.criticalFillPercent).toList();

    final smartStops = _nearestNeighbor(critical);
    final smartKm = _tourLengthKm(critical, smartStops, includeReturn: true);

    // Old policy: visit every bin, always, in a naive order (zone then name).
    final naive = [...allBins]..sort((a, b) {
        final z = a.zone.compareTo(b.zone);
        return z != 0 ? z : a.name.compareTo(b.name);
      });
    final baselineStops = [
      for (var i = 0; i < naive.length; i++)
        RouteStop(binId: naive[i].id, order: i + 1),
    ];
    final baselineKm = _tourLengthKm(naive, baselineStops, includeReturn: true);

    return CollectionRoute(
      stops: smartStops,
      smartDistanceKm: smartKm,
      baselineDistanceKm: baselineKm,
    );
  }

  /// Core greedy loop. Read this function for the viva.
  List<RouteStop> _nearestNeighbor(List<Bin> bins) {
    if (bins.isEmpty) return const [];

    final remaining = [...bins];
    final ordered = <Bin>[];

    // "Where is the truck right now?" — start at the depot, not at a bin.
    var currentLat = AppConfig.depotLat;
    var currentLng = AppConfig.depotLng;

    while (remaining.isNotEmpty) {
      // Linear scan for the geographically closest leftover bin.
      var bestIndex = 0;
      var bestKm = double.infinity;
      for (var i = 0; i < remaining.length; i++) {
        final km = haversineKm(
          currentLat,
          currentLng,
          remaining[i].lat,
          remaining[i].lng,
        );
        if (km < bestKm) {
          bestKm = km;
          bestIndex = i;
        }
      }

      final next = remaining.removeAt(bestIndex);
      ordered.add(next);
      currentLat = next.lat;
      currentLng = next.lng;
    }

    return [
      for (var i = 0; i < ordered.length; i++)
        RouteStop(binId: ordered[i].id, order: i + 1),
    ];
  }

  /// Walk the tour in [stops] order and sum haversine legs.
  /// If [includeReturn] is true we add depot → first and last → depot.
  double _tourLengthKm(
    List<Bin> bins,
    List<RouteStop> stops, {
    required bool includeReturn,
  }) {
    if (stops.isEmpty) return 0;

    final byId = {for (final b in bins) b.id: b};
    var total = 0.0;
    var lat = AppConfig.depotLat;
    var lng = AppConfig.depotLng;

    for (final stop in stops) {
      final bin = byId[stop.binId];
      if (bin == null) continue;
      total += haversineKm(lat, lng, bin.lat, bin.lng);
      lat = bin.lat;
      lng = bin.lng;
    }

    if (includeReturn) {
      total += haversineKm(lat, lng, AppConfig.depotLat, AppConfig.depotLng);
    }
    return total;
  }
}
