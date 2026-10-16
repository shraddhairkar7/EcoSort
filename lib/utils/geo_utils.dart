import 'dart:math';

/// Earth-radius haversine distance in kilometres.
///
/// Why haversine? Bin coordinates are lat/lng on a sphere. A plain
/// Euclidean (x,y) distance would be wrong by several percent even at
/// city scale, which would mess up the "fuel saved" demo numbers.
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRad(lat2 - lat1);
  final dLng = _toRad(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

double _toRad(double deg) => deg * pi / 180.0;
