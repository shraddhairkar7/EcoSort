/// Central switches for the whole app.
///
/// MOCK MODE (default): AppConfig.useFirebase = false
///   - Login uses hardcoded demo accounts.
///   - Bins / reports / users live in memory (MockDataService).
///   - No google-services.json, no Firebase project, no Maps key needed.
///
/// FIREBASE MODE: set useFirebase = true AFTER following README.md
///   ("Switching from mock to Firebase").
///
/// MAPS: leave googleMapsApiKey empty to use the custom-painted fallback
///   map (SimpleCampusMap). Paste a real key to enable google_maps_flutter.
class AppConfig {
  /// Flip this to true once Firebase is configured (see README).
  static const bool useFirebase = false;

  /// Paste your Google Maps SDK key here, AND put the same value in
  /// android/app/src/main/AndroidManifest.xml (and iOS AppDelegate).
  /// Leave empty for the painted fallback map — the app still runs.
  static const String googleMapsApiKey = '';

  /// True when we should instantiate a real [GoogleMap] widget.
  static bool get hasGoogleMapsKey => googleMapsApiKey.trim().isNotEmpty;

  /// Depot used as the start/end of every collection route
  /// (college main gate — fictional campus in Pune).
  static const double depotLat = 18.5204;
  static const double depotLng = 73.8567;

  /// Assumed diesel use of the collection truck (litres per km).
  /// Used only for the fuel-saved comparison UI.
  static const double litresPerKm = 0.12;

  /// Assumed CO2 kg per litre of diesel (rough educational figure).
  static const double kgCo2PerLitre = 2.68;

  /// Bins at or above this fill % are included in today's smart route.
  static const int criticalFillPercent = 80;
}
