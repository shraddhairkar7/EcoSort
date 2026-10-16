/// Citizen-submitted problem at (or near) a bin.
class IssueReport {
  final String id;
  final String userId;

  /// May be empty if the report is "illegal dumping" not tied to a bin.
  final String binId;

  /// Local file path in mock mode; download URL in Firebase mode.
  final String photoUrl;
  final IssueCategory category;
  final double lat;
  final double lng;
  final IssueStatus status;
  final DateTime timestamp;
  final String notes;

  const IssueReport({
    required this.id,
    required this.userId,
    required this.binId,
    required this.photoUrl,
    required this.category,
    required this.lat,
    required this.lng,
    required this.status,
    required this.timestamp,
    this.notes = '',
  });

  IssueReport copyWith({IssueStatus? status, String? photoUrl}) {
    return IssueReport(
      id: id,
      userId: userId,
      binId: binId,
      photoUrl: photoUrl ?? this.photoUrl,
      category: category,
      lat: lat,
      lng: lng,
      status: status ?? this.status,
      timestamp: timestamp,
      notes: notes,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'binId': binId,
        'photoUrl': photoUrl,
        'category': category.name,
        'lat': lat,
        'lng': lng,
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
        'notes': notes,
      };

  factory IssueReport.fromMap(Map<String, dynamic> map) {
    return IssueReport(
      id: map['id'] as String,
      userId: map['userId'] as String,
      binId: map['binId'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      category: IssueCategory.values.byName(map['category'] as String),
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      status: IssueStatus.values.byName(map['status'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
      notes: map['notes'] as String? ?? '',
    );
  }
}

enum IssueCategory { overflowing, damaged, illegalDumping }

enum IssueStatus { open, resolved }

extension IssueCategoryLabel on IssueCategory {
  String get label {
    switch (this) {
      case IssueCategory.overflowing:
        return 'Overflowing';
      case IssueCategory.damaged:
        return 'Damaged';
      case IssueCategory.illegalDumping:
        return 'Illegal dumping';
    }
  }
}
