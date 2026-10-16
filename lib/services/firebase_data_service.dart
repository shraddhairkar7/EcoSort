import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:ecosort/models/analytics.dart';
import 'package:ecosort/models/bin.dart';
import 'package:ecosort/models/issue_report.dart';
import 'package:ecosort/models/user.dart';
import 'package:ecosort/services/data_service.dart';

/// =====================================================================
/// FIREBASE IMPLEMENTATION  — same interface as MockDataService.
///
/// This class is compiled into the app but is ONLY constructed when
/// AppConfig.useFirebase == true (see lib/services/service_locator.dart).
///
/// Before flipping that flag:
///   1. Create a Firebase project and enable Auth + Firestore + Storage.
///   2. Run `flutterfire configure` (or drop google-services.json /
///      GoogleService-Info.plist into the platform folders).
///   3. Uncomment the Google Services Gradle plugin (README).
///   4. Set AppConfig.useFirebase = true.
///
/// Suggested Firestore collections:
///   users/{uid}          — AppUser.toMap()
///   bins/{binId}         — Bin.toMap()
///   issueReports/{id}    — IssueReport.toMap()
///   dailyStats/{yyyyMMdd}
/// =====================================================================
class FirebaseDataService implements DataService {
  FirebaseDataService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  /// Call once from main() when useFirebase is true.
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _bins =>
      _db.collection('bins');
  CollectionReference<Map<String, dynamic>> get _issues =>
      _db.collection('issueReports');
  CollectionReference<Map<String, dynamic>> get _stats =>
      _db.collection('dailyStats');

  @override
  Future<AppUser?> login({
    required String email,
    required String password,
    UserRole? roleOverride,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user?.uid;
    if (uid == null) return null;
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    var user = AppUser.fromMap({...doc.data()!, 'id': uid});
    if (roleOverride != null) {
      user = user.copyWith(role: roleOverride);
    }
    return user;
  }

  @override
  Future<List<AppUser>> getUsers() async {
    final snap = await _users.get();
    return snap.docs
        .map((d) => AppUser.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }

  @override
  Future<AppUser> addScore({required String userId, required int delta}) async {
    final ref = _users.doc(userId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = (snap.data()?['segregationScore'] as int?) ?? 0;
      tx.update(ref, {'segregationScore': current + delta});
    });
    final updated = await ref.get();
    return AppUser.fromMap({...updated.data()!, 'id': userId});
  }

  @override
  Future<List<Bin>> getBins() async {
    final snap = await _bins.get();
    return snap.docs
        .map((d) => Bin.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }

  @override
  Future<Bin> upsertBin(Bin bin) async {
    await _bins.doc(bin.id).set(bin.toMap());
    return bin;
  }

  @override
  Future<void> deleteBin(String id) async {
    await _bins.doc(id).delete();
  }

  @override
  Future<List<IssueReport>> getIssueReports() async {
    final snap = await _issues.orderBy('timestamp', descending: true).get();
    return snap.docs
        .map((d) => IssueReport.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }

  @override
  Future<IssueReport> submitIssue(IssueReport report) async {
    var photoUrl = report.photoUrl;
    // Local camera path → Cloud Storage download URL.
    if (photoUrl.isNotEmpty && !photoUrl.startsWith('http')) {
      final ref = _storage.ref('issue_photos/${report.id}.jpg');
      await ref.putFile(File(photoUrl));
      photoUrl = await ref.getDownloadURL();
    }
    final toSave = report.copyWith(photoUrl: photoUrl);
    await _issues.doc(report.id).set(toSave.toMap());
    return toSave;
  }

  @override
  Future<IssueReport> setIssueStatus({
    required String id,
    required IssueStatus status,
  }) async {
    await _issues.doc(id).update({'status': status.name});
    final doc = await _issues.doc(id).get();
    return IssueReport.fromMap({...doc.data()!, 'id': id});
  }

  @override
  Future<List<DailyCollectionStat>> getDailyStats() async {
    final snap = await _stats.orderBy('day').get();
    return snap.docs.map((d) {
      final m = d.data();
      return DailyCollectionStat(
        day: DateTime.parse(m['day'] as String),
        collections: m['collections'] as int,
        tripsSaved: m['tripsSaved'] as int,
        avgFillPercent: (m['avgFillPercent'] as num).toDouble(),
      );
    }).toList();
  }
}
