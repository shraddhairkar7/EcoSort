import 'package:flutter/material.dart';

import 'package:ecosort/models/bin.dart';
import 'package:ecosort/theme/app_theme.dart';
import 'package:ecosort/widgets/fill_level_badge.dart';

class BinCard extends StatelessWidget {
  const BinCard({
    super.key,
    required this.bin,
    this.onTap,
    this.trailing,
    this.subtitle,
  });

  final Bin bin;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: FillLevelBadge.colorFor(bin.fillLevelPercent),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        title: Text(bin.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          subtitle ??
              '${bin.zone} · ${bin.type.label} · ${bin.capacityLitres} L',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        trailing: trailing ?? FillLevelBadge(percent: bin.fillLevelPercent),
      ),
    );
  }
}
