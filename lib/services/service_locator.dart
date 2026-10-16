import 'package:ecosort/config/app_config.dart';
import 'package:ecosort/services/data_service.dart';
import 'package:ecosort/services/firebase_data_service.dart';
import 'package:ecosort/services/mock_data_service.dart';

/// Single place that decides which backend the rest of the app gets.
///
/// Touch THIS file + AppConfig.useFirebase when you switch to Firebase.
DataService createDataService() {
  if (AppConfig.useFirebase) {
    return FirebaseDataService();
  }
  return MockDataService();
}
