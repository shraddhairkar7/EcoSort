import 'package:flutter/material.dart';

import 'package:ecosort/theme/app_theme.dart';

/// Traffic-light chip: green <50, yellow 50–79, red >=80.
class FillLevelBadge extends StatelessWidget {
  const FillLevelBadge({super.key, required this.percent, this.compact = false});

  final int percent;
  final bool compact;

  static Color colorFor(int percent) {
    if (percent >= 80) return AppColors.fillRed;
    if (percent >= 50) return AppColors.fillYellow;
    return AppColors.fillGreen;
  }

  static String labelFor(int percent) {
    if (percent >= 80) return 'Critical';
    if (percent >= 50) return 'Filling';
    return 'OK';
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(percent);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        compact ? '$percent%' : '${labelFor(percent)} · $percent%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 11 : 13,
        ),
      ),
    );
  }
}
