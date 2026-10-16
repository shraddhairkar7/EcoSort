import 'package:ecosort/models/bin.dart';

/// Entry in the Waste Sorting Helper catalogue.
class WasteItem {
  final String name;
  final List<String> aliases;
  final BinType binType;
  final String tip;

  const WasteItem({
    required this.name,
    required this.binType,
    required this.tip,
    this.aliases = const [],
  });

  bool matches(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return true;
    if (name.toLowerCase().contains(q)) return true;
    return aliases.any((a) => a.toLowerCase().contains(q));
  }
}
