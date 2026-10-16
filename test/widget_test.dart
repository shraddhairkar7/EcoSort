import 'package:flutter_test/flutter_test.dart';

import 'package:ecosort/models/bin.dart';
import 'package:ecosort/utils/route_optimizer.dart';

void main() {
  test('nearest-neighbor only visits critical bins', () {
    final now = DateTime.now();
    final bins = [
      Bin(
        id: 'low',
        name: 'Low',
        lat: 18.52,
        lng: 73.85,
        fillLevelPercent: 20,
        type: BinType.dry,
        zone: 'A',
        capacityLitres: 120,
        lastUpdated: now,
      ),
      Bin(
        id: 'high',
        name: 'High',
        lat: 18.53,
        lng: 73.86,
        fillLevelPercent: 90,
        type: BinType.wet,
        zone: 'A',
        capacityLitres: 120,
        lastUpdated: now,
      ),
    ];
    final route = const RouteOptimizer().buildTodayRoute(bins);
    expect(route.stops.length, 1);
    expect(route.stops.first.binId, 'high');
    expect(route.smartDistanceKm, greaterThan(0));
    expect(route.baselineDistanceKm, greaterThan(route.smartDistanceKm));
  });
}
