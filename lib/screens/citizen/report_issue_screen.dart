import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/models/issue_report.dart';
import 'package:ecosort/providers/auth_provider.dart';
import 'package:ecosort/providers/bin_provider.dart';
import 'package:ecosort/providers/impact_provider.dart';
import 'package:ecosort/providers/issue_provider.dart';
import 'package:ecosort/services/location_service.dart';
import 'package:ecosort/theme/app_theme.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _notes = TextEditingController();
  final _picker = ImagePicker();
  final _location = LocationService();

  IssueCategory _category = IssueCategory.overflowing;
  String _binId = '';
  String? _photoPath;
  double _lat = 0;
  double _lng = 0;
  bool _gpsFallback = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    final pos = await _location.currentLatLng();
    if (!mounted) return;
    setState(() {
      _lat = pos.lat;
      _lng = pos.lng;
      _gpsFallback = pos.isFallback;
    });
  }

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 70);
    if (file == null) return;
    setState(() => _photoPath = file.path);
  }

  Future<void> _submit() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    setState(() => _busy = true);
    final report = IssueReport(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      binId: _binId,
      photoUrl: _photoPath ?? '',
      category: _category,
      lat: _lat,
      lng: _lng,
      status: IssueStatus.open,
      timestamp: DateTime.now(),
      notes: _notes.text.trim(),
    );
    await context.read<IssueProvider>().submit(report);
    // +15 points for a useful civic report.
    final updated = await context.read<ImpactProvider>().award(
          userId: user.id,
          delta: 15,
        );
    if (!mounted) return;
    context.read<AuthProvider>().updateUser(updated);
    setState(() {
      _busy = false;
      _notes.clear();
      _photoPath = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report sent. +15 segregation points!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bins = context.watch<BinProvider>().bins;

    return Scaffold(
      appBar: AppBar(title: const Text('Report an issue')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final c in IssueCategory.values)
                ChoiceChip(
                  label: Text(c.label),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _binId,
            decoration: const InputDecoration(labelText: 'Related bin (optional)'),
            items: [
              const DropdownMenuItem(value: '', child: Text('None / nearby dumping')),
              for (final b in bins)
                DropdownMenuItem(value: b.id, child: Text(b.name)),
            ],
            onChanged: (v) => setState(() => _binId = v ?? ''),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'What did you see?',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.my_location, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _gpsFallback
                      ? 'GPS unavailable — using campus depot ($_lat, $_lng)'
                      : 'GPS $_lat, $_lng',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ),
              TextButton(onPressed: _locate, child: const Text('Refresh')),
            ],
          ),
          const SizedBox(height: 12),
          if (_photoPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(_photoPath!), height: 160, fit: BoxFit.cover),
            )
          else
            Container(
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('No photo yet (optional)'),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(_busy ? 'Sending…' : 'Submit report'),
          ),
        ],
      ),
    );
  }
}
