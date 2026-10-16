import 'package:geolocator/geolocator.dart';

import 'package:ecosort/config/app_config.dart';

/// Thin wrapper around geolocator so screens don't care about permission
/// plumbing. If GPS is denied / unavailable we fall back to the depot
/// so "Report an Issue" still works in the emulator.
class LocationService {
  Future<({double lat, double lng, bool isFallback})> currentLatLng() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return (
          lat: AppConfig.depotLat,
          lng: AppConfig.depotLng,
          isFallback: true
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (
          lat: AppConfig.depotLat,
          lng: AppConfig.depotLng,
          isFallback: true
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return (lat: pos.latitude, lng: pos.longitude, isFallback: false);
    } catch (_) {
      return (
        lat: AppConfig.depotLat,
        lng: AppConfig.depotLng,
        isFallback: true
      );
    }
  }
}
