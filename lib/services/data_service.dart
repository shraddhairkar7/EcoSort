import 'package:ecosort/models/analytics.dart';
import 'package:ecosort/models/bin.dart';
import 'package:ecosort/models/issue_report.dart';
import 'package:ecosort/models/user.dart';

/// Contract every backend must honour.
///
/// Screens and providers talk ONLY to this interface. That is why we can
/// ship with [MockDataService] today and swap in [FirebaseDataService]
/// later by changing one flag in AppConfig — no UI rewrite.
abstract class DataService {
  Future<AppUser?> login({
    required String email,
    required String password,
    UserRole? roleOverride,
  });

  Future<List<AppUser>> getUsers();

  Future<AppUser> addScore({required String userId, required int delta});

  Future<List<Bin>> getBins();

  Future<Bin> upsertBin(Bin bin);

  Future<void> deleteBin(String id);

  Future<List<IssueReport>> getIssueReports();

  Future<IssueReport> submitIssue(IssueReport report);

  Future<IssueReport> setIssueStatus({
    required String id,
    required IssueStatus status,
  });

  Future<List<DailyCollectionStat>> getDailyStats();
}
