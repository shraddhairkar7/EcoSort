/// Physical smart bin placed somewhere on campus / in the city.
///
/// [fillLevelPercent] is 0–100. The UI maps it to green / yellow / red
/// (see [Bin.fillColor] and FillLevelBadge).
class Bin {
  final String id;
  final String name;

  /// Geographic coordinates (WGS84). Used by the map AND the route optimizer.
  final double lat;
  final double lng;

  /// How full the bin is right now. Collectors only visit bins >= 80%.
  final int fillLevelPercent;

  /// Waste stream this bin is meant for.
  final BinType type;

  /// Campus / city zone label (North / South / Downtown in the seed data).
  final String zone;

  /// Max litres the bin can hold (used on the admin CRUD form).
  final int capacityLitres;

  final DateTime lastUpdated;

  const Bin({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.fillLevelPercent,
    required this.type,
    required this.zone,
    required this.capacityLitres,
    required this.lastUpdated,
  });

  bool get isCritical => fillLevelPercent >= 80;

  Bin copyWith({
    String? id,
    String? name,
    double? lat,
    double? lng,
    int? fillLevelPercent,
    BinType? type,
    String? zone,
    int? capacityLitres,
    DateTime? lastUpdated,
  }) {
    return Bin(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      fillLevelPercent: fillLevelPercent ?? this.fillLevelPercent,
      type: type ?? this.type,
      zone: zone ?? this.zone,
      capacityLitres: capacityLitres ?? this.capacityLitres,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
        'fillLevelPercent': fillLevelPercent,
        'type': type.name,
        'zone': zone,
        'capacityLitres': capacityLitres,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory Bin.fromMap(Map<String, dynamic> map) {
    return Bin(
      id: map['id'] as String,
      name: map['name'] as String,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      fillLevelPercent: map['fillLevelPercent'] as int,
      type: BinType.values.byName(map['type'] as String),
      zone: map['zone'] as String? ?? 'Unknown',
      capacityLitres: map['capacityLitres'] as int? ?? 120,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }
}

enum BinType { general, wet, dry, recyclable }

extension BinTypeLabel on BinType {
  String get label {
    switch (this) {
      case BinType.general:
        return 'General';
      case BinType.wet:
        return 'Wet / Organic';
      case BinType.dry:
        return 'Dry';
      case BinType.recyclable:
        return 'Recyclable';
    }
  }
}
