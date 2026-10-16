/// One day of mock historical collection stats for fl_chart.
class DailyCollectionStat {
  final DateTime day;
  final int collections;
  final int tripsSaved;
  final double avgFillPercent;

  const DailyCollectionStat({
    required this.day,
    required this.collections,
    required this.tripsSaved,
    required this.avgFillPercent,
  });
}

class ZoneFillStat {
  final String zone;
  final double avgFillPercent;

  const ZoneFillStat({required this.zone, required this.avgFillPercent});
}
