import 'package:flutter/foundation.dart';

import 'package:ecosort/models/issue_report.dart';
import 'package:ecosort/services/data_service.dart';

class IssueProvider extends ChangeNotifier {
  IssueProvider(this._data);

  final DataService _data;
  List<IssueReport> reports = [];
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    reports = await _data.getIssueReports();
    isLoading = false;
    notifyListeners();
  }

  Future<void> submit(IssueReport report) async {
    await _data.submitIssue(report);
    await load();
  }

  Future<void> resolve(String id) async {
    await _data.setIssueStatus(id: id, status: IssueStatus.resolved);
    await load();
  }

  List<IssueReport> openNearBins(Set<String> binIds) {
    return reports
        .where((r) =>
            r.status == IssueStatus.open &&
            (binIds.contains(r.binId) || r.binId.isEmpty))
        .toList();
  }
}
