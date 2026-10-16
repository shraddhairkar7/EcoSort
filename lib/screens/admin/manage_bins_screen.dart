import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/models/bin.dart';
import 'package:ecosort/providers/bin_provider.dart';
import 'package:ecosort/providers/route_provider.dart';
import 'package:ecosort/widgets/bin_card.dart';

class ManageBinsScreen extends StatelessWidget {
  const ManageBinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bins = context.watch<BinProvider>().bins;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage bins')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, null),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: bins.length,
        itemBuilder: (_, i) {
          final bin = bins[i];
          return BinCard(
            bin: bin,
            onTap: () => _edit(context, bin),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await context.read<BinProvider>().remove(bin.id);
                if (context.mounted) {
                  context
                      .read<RouteProvider>()
                      .rebuild(context.read<BinProvider>().bins);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _edit(BuildContext context, Bin? existing) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final lat = TextEditingController(text: existing?.lat.toString() ?? '18.5204');
    final lng = TextEditingController(text: existing?.lng.toString() ?? '73.8567');
    final fill = TextEditingController(
      text: existing?.fillLevelPercent.toString() ?? '10',
    );
    final cap = TextEditingController(
      text: existing?.capacityLitres.toString() ?? '120',
    );
    var type = existing?.type ?? BinType.general;
    var zone = existing?.zone ?? 'Campus North';

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setLocal) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(existing == null ? 'Add bin' : 'Edit bin',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: lat,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: lng,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: fill,
                      decoration:
                          const InputDecoration(labelText: 'Fill % (0–100)'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: cap,
                      decoration: const InputDecoration(labelText: 'Capacity (L)'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<BinType>(
                      // ignore: deprecated_member_use
                      value: type,
                      items: [
                        for (final t in BinType.values)
                          DropdownMenuItem(value: t, child: Text(t.label)),
                      ],
                      onChanged: (v) => setLocal(() => type = v ?? type),
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: zone,
                      items: const [
                        DropdownMenuItem(
                            value: 'Campus North', child: Text('Campus North')),
                        DropdownMenuItem(
                            value: 'Campus South', child: Text('Campus South')),
                        DropdownMenuItem(
                            value: 'Downtown', child: Text('Downtown')),
                      ],
                      onChanged: (v) => setLocal(() => zone = v ?? zone),
                      decoration: const InputDecoration(labelText: 'Zone'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Save'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (saved != true || !context.mounted) {
      name.dispose();
      lat.dispose();
      lng.dispose();
      fill.dispose();
      cap.dispose();
      return;
    }
    final bin = Bin(
      id: existing?.id ?? 'b${DateTime.now().millisecondsSinceEpoch}',
      name: name.text.trim().isEmpty ? 'Untitled bin' : name.text.trim(),
      lat: double.tryParse(lat.text) ?? 18.5204,
      lng: double.tryParse(lng.text) ?? 73.8567,
      fillLevelPercent: (int.tryParse(fill.text) ?? 0).clamp(0, 100),
      type: type,
      zone: zone,
      capacityLitres: int.tryParse(cap.text) ?? 120,
      lastUpdated: DateTime.now(),
    );
    await context.read<BinProvider>().save(bin);
    if (context.mounted) {
      context.read<RouteProvider>().rebuild(context.read<BinProvider>().bins);
    }
    name.dispose();
    lat.dispose();
    lng.dispose();
    fill.dispose();
    cap.dispose();
  }
}
