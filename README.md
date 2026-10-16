# EcoSort

College mini-project for **SDG 11 — Sustainable Cities and Communities**.

EcoSort is a Flutter app that helps a campus (or small city) **segregate waste**, **report bin problems**, and **collect only the bins that are actually full**. Collection order is computed with a nearest-neighbor route so the truck drives fewer kilometres than a fixed “visit every bin” loop.

The app ships in **mock mode**: it runs with hardcoded bins, users, and reports. You do **not** need Firebase keys or a Google Maps key to `flutter run` or to build a release APK.

## Features by role

| Role | What you get |
| --- | --- |
| **Citizen** | Nearby bins (list + map), report an issue (photo + GPS), waste sorting helper, personal score + leaderboard + CO₂ estimate |
| **Collector** | Today’s route (bins ≥ 80% full, nearest-neighbor order), swipe/tap Collected, smart vs baseline km/fuel, issues on that route |
| **Admin** | All bins on a map, fl_chart analytics, CRUD bins, resolve citizen reports |

Demo logins (password is the role name + `123`):

- `citizen@ecosort.app` / `citizen123`
- `collector@ecosort.app` / `collector123`
- `admin@ecosort.app` / `admin123`

The login screen also has a **role selector**. It overrides the account’s stored role so you can demo all three flows quickly.

## Architecture (for the project report)

```
UI screens  →  Providers (ChangeNotifier)  →  DataService interface
                                              ├── MockDataService   (default)
                                              └── FirebaseDataService (opt-in)
```

- **Screens** never talk to Firestore or to the mock lists directly.
- **Providers** hold UI state and call the interface.
- **Switching backend** is one flag: `AppConfig.useFirebase` in `lib/config/app_config.dart`, plus the factory in `lib/services/service_locator.dart`.

### Folder map

| Path | Responsibility |
| --- | --- |
| `lib/main.dart` | Starts Firebase only if enabled; wires Provider tree |
| `lib/config/app_config.dart` | Mock/Firebase switch, Maps key, depot, fuel factors |
| `lib/models/` | `Bin`, `AppUser`, `IssueReport`, `RouteStop`, analytics |
| `lib/services/data_service.dart` | Abstract backend API |
| `lib/services/mock_data_service.dart` | In-memory seed data (16 bins, 5 users, reports) |
| `lib/services/firebase_data_service.dart` | Same API on Auth + Firestore + Storage |
| `lib/providers/` | Auth, bins, issues, route, impact |
| `lib/screens/{auth,citizen,collector,admin}/` | Role UIs |
| `lib/widgets/` | `BinCard`, `FillLevelBadge`, `StatCounter`, `EcoMap` |
| `lib/utils/route_optimizer.dart` | Nearest-neighbor collection tour |
| `lib/utils/waste_catalogue.dart` | Sorting-helper lookup table |

### Route optimizer (explain this in the viva)

File: `lib/utils/route_optimizer.dart`

1. Keep only bins with fill ≥ 80% (`AppConfig.criticalFillPercent`).
2. Start the truck at the **depot** (college gate coordinates).
3. Repeatedly pick the **closest unvisited** critical bin (haversine km).
4. Sum the path, then add the return to the depot.
5. Compare against a **baseline**: visit **every** bin in zone/name order (the old dumb route).

That is a greedy TSP heuristic: **O(n²)** time, easy to dry-run on a whiteboard. It is not guaranteed optimal; for a demo with ~15 bins it is good enough and honest to say so.

## Run (mock mode)

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) on your PATH.

```bash
cd path/to/MDM
flutter pub get
flutter run
```

If this folder was copied without a full Android/iOS project, generate platform files **once** (it will not delete `lib/`):

```bash
flutter create . --project-name ecosort --org com.sdg11 --platforms=android,ios
```

If `flutter create` overwrites `AndroidManifest.xml`, put back:

- camera + location permissions
- `com.google.android.geo.API_KEY` meta-data (placeholder is fine in mock mode)

### Release APK

```bash
flutter build apk --release
```

The APK is written to:

`build/app/outputs/flutter-apk/app-release.apk`

Release signing uses the **debug keystore** on purpose so a student machine can build without `key.properties`. For Play Store, replace `signingConfig` in `android/app/build.gradle`.

## Switching from mock to Firebase

1. Create a Firebase project. Enable **Email/Password Auth**, **Cloud Firestore**, **Storage**.
2. Install the FlutterFire CLI and generate options:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. Drop `google-services.json` into `android/app/` (and `GoogleService-Info.plist` into `ios/Runner/`).
4. Uncomment the Google Services plugin in:
   - `android/settings.gradle`
   - `android/app/build.gradle`
5. Delete the `FirebaseInitProvider` `tools:node="remove"` block in
   `android/app/src/main/AndroidManifest.xml` (it is only there so mock
   mode does not crash without `google-services.json`).
6. Set in `lib/config/app_config.dart`:
   ```dart
   static const bool useFirebase = true;
   ```
7. Seed Firestore collections to match the maps in the models (`users`, `bins`, `issueReports`, `dailyStats`). `FirebaseDataService` already uses those names.
8. Rebuild:
   ```bash
   flutter pub get
   flutter run
   ```

Until step 5, Firebase packages sit in `pubspec.yaml` but **`Firebase.initializeApp()` is never called**.

## Google Maps (optional)

Default: `AppConfig.googleMapsApiKey` is empty, so `EcoMap` draws a **custom-painted campus map** with colour-coded dots (green / yellow / red fill).

To use real Google Maps:

1. Create a Maps SDK key (Android + iOS restrictions).
2. Put the key in `lib/config/app_config.dart`.
3. Put the **same** key in `android/app/src/main/AndroidManifest.xml` (`com.google.android.geo.API_KEY`).
4. On iOS, `import GoogleMaps` in `AppDelegate.swift` and call `GMSServices.provideAPIKey(...)`.

## Colour scheme

| Token | Hex |
| --- | --- |
| Primary (forest) | `#1F4E3D` |
| Secondary (moss) | `#7CA982` |
| Accent | `#E8871E` |
| Background | `#FFFFFF` |

Defined in `lib/theme/app_theme.dart`.

## Adding a feature later (touch 2–3 files)

Example: “Citizen can favourite a bin.”

1. `lib/models/` + `lib/services/data_service.dart` (+ mock/firebase implementations) — data.
2. `lib/providers/bin_provider.dart` — state.
3. A screen under `lib/screens/citizen/` — UI.

You should **not** need to change login, the other roles, or the route optimizer unless the feature is about routing.

## Packages

`provider`, `fl_chart`, `image_picker`, `geolocator`, `cached_network_image`, `google_maps_flutter`, plus FlutterFire (`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`).
