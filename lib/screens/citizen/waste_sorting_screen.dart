import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/models/bin.dart';
import 'package:ecosort/models/waste_item.dart';
import 'package:ecosort/providers/auth_provider.dart';
import 'package:ecosort/providers/impact_provider.dart';
import 'package:ecosort/theme/app_theme.dart';
import 'package:ecosort/utils/waste_catalogue.dart';

class WasteSortingScreen extends StatefulWidget {
  const WasteSortingScreen({super.key});

  @override
  State<WasteSortingScreen> createState() => _WasteSortingScreenState();
}

class _WasteSortingScreenState extends State<WasteSortingScreen> {
  String _query = '';
  WasteItem? _selected;

  @override
  Widget build(BuildContext context) {
    final results = kWasteCatalogue.where((w) => w.matches(_query)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Waste sorting helper')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() {
                _query = v;
                _selected = null;
              }),
              decoration: const InputDecoration(
                hintText: 'Search or type an item (e.g. banana peel)',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (_selected != null) _ResultCard(item: _selected!, onAwarded: _award),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final item = results[i];
                return ListTile(
                  leading: Icon(_icon(item.binType), color: AppColors.primary),
                  title: Text(item.name),
                  subtitle: Text(item.binType.label),
                  onTap: () => setState(() => _selected = item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _award() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final updated = await context.read<ImpactProvider>().award(
          userId: user.id,
          delta: 5,
        );
    if (!mounted) return;
    context.read<AuthProvider>().updateUser(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('+5 points for checking a sort!')),
    );
  }

  IconData _icon(BinType t) {
    switch (t) {
      case BinType.wet:
        return Icons.eco;
      case BinType.dry:
        return Icons.inventory_2_outlined;
      case BinType.recyclable:
        return Icons.recycling;
      case BinType.general:
        return Icons.delete_outline;
    }
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.item, required this.onAwarded});
  final WasteItem item;
  final VoidCallback onAwarded;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.surfaceMuted,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Chip(
              label: Text('Put in: ${item.binType.label}'),
              backgroundColor: AppColors.secondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(item.tip),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onAwarded,
              icon: const Icon(Icons.stars_outlined),
              label: const Text('I sorted this correctly'),
            ),
          ],
        ),
      ),
    );
  }
}
