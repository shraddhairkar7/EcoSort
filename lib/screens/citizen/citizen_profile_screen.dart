import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/config/app_config.dart';
import 'package:ecosort/providers/auth_provider.dart';
import 'package:ecosort/screens/auth/login_screen.dart';
import 'package:ecosort/theme/app_theme.dart';

class CitizenProfileScreen extends StatelessWidget {
  const CitizenProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary,
            child: Text(
              (user?.name ?? '?').substring(0, 1),
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(user?.name ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(user?.email ?? '',
              style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Chip(label: Text(user?.role.name ?? '')),
          const Divider(height: 32),
          SwitchListTile(
            title: const Text('Mock data mode'),
            subtitle: Text(AppConfig.useFirebase
                ? 'Firebase is ON — see README to revert'
                : 'Using in-memory MockDataService'),
            value: !AppConfig.useFirebase,
            onChanged: null,
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About EcoSort'),
            subtitle: Text(
              'College mini-project for SDG 11 (Sustainable Cities). '
              'Smart bins, citizen reports, and optimized collection routes.',
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
