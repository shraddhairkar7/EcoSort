import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/models/bin.dart';
import 'package:ecosort/providers/auth_provider.dart';
import 'package:ecosort/providers/bin_provider.dart';
import 'package:ecosort/theme/app_theme.dart';
import 'package:ecosort/widgets/bin_card.dart';
import 'package:ecosort/widgets/eco_map.dart';
import 'package:ecosort/widgets/fill_level_badge.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  bool _showMap = true;
  String _zone = 'All';

  @override
  Widget build(BuildContext context) {
    final bins = context.watch<BinProvider>().bins;
    final name = context.watch<AuthProvider>().currentUser?.name ?? 'Citizen';
    final zones = ['All', ...{for (final b in bins) b.zone}];
    final visible =
        _zone == 'All' ? bins : bins.where((b) => b.zone == _zone).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nearby bins', style: TextStyle(fontSize: 18)),
            Text(
              'Hi $name',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _showMap ? 'List view' : 'Map view',
            onPressed: () => setState(() => _showMap = !_showMap),
            icon: Icon(_showMap ? Icons.list : Icons.map_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              children: [
                for (final z in zones)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(z),
                      selected: _zone == z,
                      onSelected: (_) => setState(() => _zone = z),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: const [
                _Legend(color: AppColors.fillGreen, label: '< 50%'),
                SizedBox(width: 12),
                _Legend(color: AppColors.fillYellow, label: '50–79%'),
                SizedBox(width: 12),
                _Legend(color: AppColors.fillRed, label: '≥ 80%'),
              ],
            ),
          ),
          if (_showMap)
            Padding(
              padding: const EdgeInsets.all(16),
              child: EcoMap(
                bins: visible,
                height: 260,
                onBinTap: (b) => _details(context, b),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: visible.length,
              itemBuilder: (_, i) => BinCard(
                bin: visible[i],
                onTap: () => _details(context, visible[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _details(BuildContext context, Bin bin) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bin.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              FillLevelBadge(percent: bin.fillLevelPercent),
              const SizedBox(height: 12),
              Text('${bin.zone} · ${bin.type.label} · ${bin.capacityLitres} L'),
              Text(
                'Updated ${_ago(bin.lastUpdated)}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
