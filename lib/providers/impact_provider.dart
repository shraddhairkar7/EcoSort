import 'package:flutter/foundation.dart';

import 'package:ecosort/config/app_config.dart';
import 'package:ecosort/models/analytics.dart';
import 'package:ecosort/models/user.dart';
import 'package:ecosort/services/data_service.dart';

class ImpactProvider extends ChangeNotifier {
  ImpactProvider(this._data);

  final DataService _data;
  List<AppUser> users = [];
  List<DailyCollectionStat> stats = [];

  Future<void> load() async {
    users = await _data.getUsers();
    stats = await _data.getDailyStats();
    notifyListeners();
  }

  List<AppUser> get leaderboard {
    final copy = [...users]..sort(
        (a, b) => b.segregationScore.compareTo(a.segregationScore),
      );
    return copy;
  }

  /// System-wide CO2 avoided by skipping empty-bin kilometres.
  double get kgCo2Saved {
    final trips = stats.fold<int>(0, (p, s) => p + s.tripsSaved);
    // Each "saved trip" is modelled as a 4 km shorter day × diesel factor.
    const kmPerSavedTrip = 4.0;
    return trips * kmPerSavedTrip * AppConfig.litresPerKm * AppConfig.kgCo2PerLitre;
  }

  Future<AppUser> award({required String userId, required int delta}) async {
    final updated = await _data.addScore(userId: userId, delta: delta);
    await load();
    return updated;
  }
}
