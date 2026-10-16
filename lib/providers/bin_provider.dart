import 'package:flutter/foundation.dart';

import 'package:ecosort/models/bin.dart';
import 'package:ecosort/services/data_service.dart';

class BinProvider extends ChangeNotifier {
  BinProvider(this._data);

  final DataService _data;
  List<Bin> bins = [];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      bins = await _data.getBins();
    } catch (e) {
      error = '$e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Bin? byId(String id) {
    try {
      return bins.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Bin bin) async {
    await _data.upsertBin(bin);
    await load();
  }

  Future<void> remove(String id) async {
    await _data.deleteBin(id);
    await load();
  }

  List<String> get zones =>
      {for (final b in bins) b.zone}.toList()..sort();
}
