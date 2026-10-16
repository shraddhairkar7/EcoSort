import 'package:ecosort/models/analytics.dart';
import 'package:ecosort/models/bin.dart';
import 'package:ecosort/models/issue_report.dart';
import 'package:ecosort/models/user.dart';
import 'package:ecosort/services/data_service.dart';

/// In-memory backend. Seeded once when the object is constructed so the
/// first screen already looks populated (15 bins, 5 users, sample reports).
///
/// All lists are mutated in place — Provider then notifies listeners.
class MockDataService implements DataService {
  MockDataService() {
    _users = _seedUsers();
    _bins = _seedBins();
    _reports = _seedReports();
    _stats = _seedStats();
  }

  late List<AppUser> _users;
  late List<Bin> _bins;
  late List<IssueReport> _reports;
  late List<DailyCollectionStat> _stats;

  /// Demo passwords (never do this in production — mock mode only).
  static const Map<String, String> demoPasswords = {
    'citizen@ecosort.app': 'citizen123',
    'collector@ecosort.app': 'collector123',
    'admin@ecosort.app': 'admin123',
    'priya@ecosort.app': 'priya123',
    'arjun@ecosort.app': 'arjun123',
  };

  @override
  Future<AppUser?> login({
    required String email,
    required String password,
    UserRole? roleOverride,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final key = email.trim().toLowerCase();
    final matches = _users.where((u) => u.email == key);
    if (matches.isEmpty) return null;
    final expected = demoPasswords[key];
    if (expected != null && expected != password) return null;
    final user = matches.first;
    if (roleOverride != null && roleOverride != user.role) {
      // Role selector on the login screen can impersonate a role for demos
      // without needing a second account.
      return user.copyWith(role: roleOverride);
    }
    return user;
  }

  @override
  Future<List<AppUser>> getUsers() async => List.unmodifiable(_users);

  @override
  Future<AppUser> addScore({required String userId, required int delta}) async {
    final i = _users.indexWhere((u) => u.id == userId);
    if (i < 0) throw StateError('Unknown user $userId');
    _users[i] = _users[i].copyWith(
      segregationScore: _users[i].segregationScore + delta,
    );
    return _users[i];
  }

  @override
  Future<List<Bin>> getBins() async => List.unmodifiable(_bins);

  @override
  Future<Bin> upsertBin(Bin bin) async {
    final i = _bins.indexWhere((b) => b.id == bin.id);
    if (i >= 0) {
      _bins[i] = bin;
    } else {
      _bins.add(bin);
    }
    return bin;
  }

  @override
  Future<void> deleteBin(String id) async {
    _bins.removeWhere((b) => b.id == id);
  }

  @override
  Future<List<IssueReport>> getIssueReports() async =>
      List.unmodifiable(_reports);

  @override
  Future<IssueReport> submitIssue(IssueReport report) async {
    _reports.insert(0, report);
    return report;
  }

  @override
  Future<IssueReport> setIssueStatus({
    required String id,
    required IssueStatus status,
  }) async {
    final i = _reports.indexWhere((r) => r.id == id);
    if (i < 0) throw StateError('Unknown report $id');
    _reports[i] = _reports[i].copyWith(status: status);
    return _reports[i];
  }

  @override
  Future<List<DailyCollectionStat>> getDailyStats() async =>
      List.unmodifiable(_stats);

  // ---------------------------------------------------------------------------
  // Seed data — fictional Pune campus / neighbourhood coordinates.
  // ---------------------------------------------------------------------------

  List<AppUser> _seedUsers() => [
        const AppUser(
          id: 'u1',
          name: 'Asha Patil',
          email: 'citizen@ecosort.app',
          role: UserRole.citizen,
          segregationScore: 420,
        ),
        const AppUser(
          id: 'u2',
          name: 'Ravi Kolekar',
          email: 'collector@ecosort.app',
          role: UserRole.collector,
          segregationScore: 80,
        ),
        const AppUser(
          id: 'u3',
          name: 'Meera Deshmukh',
          email: 'admin@ecosort.app',
          role: UserRole.admin,
          segregationScore: 150,
        ),
        const AppUser(
          id: 'u4',
          name: 'Priya Shah',
          email: 'priya@ecosort.app',
          role: UserRole.citizen,
          segregationScore: 610,
        ),
        const AppUser(
          id: 'u5',
          name: 'Arjun Nair',
          email: 'arjun@ecosort.app',
          role: UserRole.citizen,
          segregationScore: 275,
        ),
      ];

  List<Bin> _seedBins() {
    final now = DateTime.now();
    return [
      // ---- Campus North (5) ----
      Bin(
        id: 'b01',
        name: 'North Gate Wet',
        lat: 18.5310,
        lng: 73.8520,
        fillLevelPercent: 92,
        type: BinType.wet,
        zone: 'Campus North',
        capacityLitres: 120,
        lastUpdated: now.subtract(const Duration(minutes: 20)),
      ),
      Bin(
        id: 'b02',
        name: 'Library Recyclable',
        lat: 18.5288,
        lng: 73.8544,
        fillLevelPercent: 41,
        type: BinType.recyclable,
        zone: 'Campus North',
        capacityLitres: 240,
        lastUpdated: now.subtract(const Duration(hours: 1)),
      ),
      Bin(
        id: 'b03',
        name: 'Canteen Wet',
        lat: 18.5296,
        lng: 73.8508,
        fillLevelPercent: 88,
        type: BinType.wet,
        zone: 'Campus North',
        capacityLitres: 240,
        lastUpdated: now.subtract(const Duration(minutes: 8)),
      ),
      Bin(
        id: 'b04',
        name: 'Hostel A Dry',
        lat: 18.5322,
        lng: 73.8555,
        fillLevelPercent: 67,
        type: BinType.dry,
        zone: 'Campus North',
        capacityLitres: 120,
        lastUpdated: now.subtract(const Duration(hours: 3)),
      ),
      Bin(
        id: 'b05',
        name: 'Sports Ground General',
        lat: 18.5335,
        lng: 73.8512,
        fillLevelPercent: 81,
        type: BinType.general,
        zone: 'Campus North',
        capacityLitres: 120,
        lastUpdated: now.subtract(const Duration(minutes: 40)),
      ),
      // ---- Campus South (5) ----
      Bin(
        id: 'b06',
        name: 'South Quad Recyclable',
        lat: 18.5148,
        lng: 73.8550,
        fillLevelPercent: 55,
        type: BinType.recyclable,
        zone: 'Campus South',
        capacityLitres: 240,
        lastUpdated: now.subtract(const Duration(hours: 2)),
      ),
      Bin(
        id: 'b07',
        name: 'Lab Block Dry',
        lat: 18.5162,
        lng: 73.8588,
        fillLevelPercent: 95,
        type: BinType.dry,
        zone: 'Campus South',
        capacityLitres: 120,
        lastUpdated: now.subtract(const Duration(minutes: 12)),
      ),
      Bin(
        id: 'b08',
        name: 'Mess Wet',
        lat: 18.5135,
        lng: 73.8572,
        fillLevelPercent: 73,
        type: BinType.wet,
        zone: 'Campus South',
        capacityLitres: 240,
        lastUpdated: now.subtract(const Duration(minutes: 50)),
      ),
      Bin(
        id: 'b09',
        name: 'Parking General',
        lat: 18.5120,
        lng: 73.8535,
        fillLevelPercent: 84,
        type: BinType.general,
        zone: 'Campus South',
        capacityLitres: 120,
        lastUpdated: now.subtract(const Duration(hours: 4)),
      ),
      Bin(
        id: 'b10',
        name: 'Auditorium Recyclable',
        lat: 18.5155,
        lng: 73.8601,
        fillLevelPercent: 22,
        type: BinType.recyclable,
        zone: 'Campus South',
        capacityLitres: 120,
        lastUpdated: now.subtract(const Duration(hours: 5)),
      ),
      // ---- Downtown (5+) ----
      Bin(
        id: 'b11',
        name: 'Market Lane Wet',
        lat: 18.5190,
        lng: 73.8702,
        fillLevelPercent: 97,
        type: BinType.wet,
        zone: 'Downtown',
        capacityLitres: 240,
        lastUpdated: now.subtract(const Duration(minutes: 5)),
      ),
      Bin(
        id: 'b12',
        name: 'Bus Stop Dry',
        lat: 18.5218,
        lng: 73.8680,
        fillLevelPercent: 64,
        type: BinType.dry,
        zone: 'Downtown',
        capacityLitres: 120,
        lastUpdated: now.subtract(const Duration(hours: 1)),
      ),
      Bin(
        id: 'b13',
        name: 'Park Recyclable',
        lat: 18.5244,
        lng: 73.8725,
        fillLevelPercent: 38,
        type: BinType.recyclable,
        zone: 'Downtown',
        capacityLitres: 120,
        lastUpdated: now.subtract(const Duration(hours: 6)),
      ),
      Bin(
        id: 'b14',
        name: 'Clinic General',
        lat: 18.5182,
        lng: 73.8664,
        fillLevelPercent: 79,
        type: BinType.general,
        zone: 'Downtown',
        capacityLitres: 120,
        lastUpdated: now.subtract(const Duration(minutes: 90)),
      ),
      Bin(
        id: 'b15',
        name: 'River Walk Wet',
        lat: 18.5260,
        lng: 73.8650,
        fillLevelPercent: 86,
        type: BinType.wet,
        zone: 'Downtown',
        capacityLitres: 240,
        lastUpdated: now.subtract(const Duration(minutes: 18)),
      ),
      Bin(
        id: 'b16',
        name: 'Station Recyclable',
        lat: 18.5228,
        lng: 73.8740,
        fillLevelPercent: 91,
        type: BinType.recyclable,
        zone: 'Downtown',
        capacityLitres: 240,
        lastUpdated: now.subtract(const Duration(minutes: 25)),
      ),
    ];
  }

  List<IssueReport> _seedReports() {
    final now = DateTime.now();
    return [
      IssueReport(
        id: 'r1',
        userId: 'u1',
        binId: 'b11',
        photoUrl: '',
        category: IssueCategory.overflowing,
        lat: 18.5190,
        lng: 73.8702,
        status: IssueStatus.open,
        timestamp: now.subtract(const Duration(hours: 2)),
        notes: 'Market lane bin overflowing after Saturday bazaar.',
      ),
      IssueReport(
        id: 'r2',
        userId: 'u4',
        binId: 'b07',
        photoUrl: '',
        category: IssueCategory.damaged,
        lat: 18.5162,
        lng: 73.8588,
        status: IssueStatus.open,
        timestamp: now.subtract(const Duration(hours: 6)),
        notes: 'Lid hinge broken — birds pulling waste out.',
      ),
      IssueReport(
        id: 'r3',
        userId: 'u5',
        binId: '',
        photoUrl: '',
        category: IssueCategory.illegalDumping,
        lat: 18.5230,
        lng: 73.8690,
        status: IssueStatus.open,
        timestamp: now.subtract(const Duration(days: 1)),
        notes: 'Construction debris dumped behind the bus stop.',
      ),
      IssueReport(
        id: 'r4',
        userId: 'u1',
        binId: 'b03',
        photoUrl: '',
        category: IssueCategory.overflowing,
        lat: 18.5296,
        lng: 73.8508,
        status: IssueStatus.resolved,
        timestamp: now.subtract(const Duration(days: 2)),
        notes: 'Canteen rush — already collected yesterday.',
      ),
    ];
  }

  List<DailyCollectionStat> _seedStats() {
    final today = DateTime.now();
    return List.generate(14, (i) {
      final day = today.subtract(Duration(days: 13 - i));
      return DailyCollectionStat(
        day: day,
        collections: 6 + (i % 5) + (i.isEven ? 2 : 0),
        tripsSaved: 1 + (i % 3),
        avgFillPercent: 58 + (i % 7) * 2.5,
      );
    });
  }
}
