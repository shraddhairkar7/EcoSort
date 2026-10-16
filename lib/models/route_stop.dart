/// One stop on a collector's optimized daily route.
class RouteStop {
  final String binId;

  /// 1-based visit order produced by [RouteOptimizer].
  final int order;
  final bool collected;

  const RouteStop({
    required this.binId,
    required this.order,
    this.collected = false,
  });

  RouteStop copyWith({int? order, bool? collected}) {
    return RouteStop(
      binId: binId,
      order: order ?? this.order,
      collected: collected ?? this.collected,
    );
  }
}

/// Snapshot of today's route plus the two distance numbers we show
/// side-by-side (smart vs baseline).
class CollectionRoute {
  final List<RouteStop> stops;

  /// Kilometres of the nearest-neighbor route over critical bins only.
  final double smartDistanceKm;

  /// Kilometres of the old "visit every bin in a fixed order" route.
  final double baselineDistanceKm;

  const CollectionRoute({
    required this.stops,
    required this.smartDistanceKm,
    required this.baselineDistanceKm,
  });

  double get distanceSavedKm =>
      (baselineDistanceKm - smartDistanceKm).clamp(0, double.infinity);
}
