import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/models/user.dart';
import 'package:ecosort/providers/auth_provider.dart';
import 'package:ecosort/providers/bin_provider.dart';
import 'package:ecosort/providers/impact_provider.dart';
import 'package:ecosort/providers/issue_provider.dart';
import 'package:ecosort/providers/route_provider.dart';
import 'package:ecosort/screens/admin/admin_shell.dart';
import 'package:ecosort/screens/citizen/citizen_shell.dart';
import 'package:ecosort/screens/collector/collector_shell.dart';
import 'package:ecosort/theme/app_theme.dart';

/// Email + password + role chip.
/// Mock login uses [MockDataService]; the selected role is passed as
/// `roleOverride` so one account can demo every shell in a viva.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'citizen@ecosort.app');
  final _password = TextEditingController(text: 'citizen123');
  UserRole _role = UserRole.citizen;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      email: _email.text,
      password: _password.text,
      role: _role,
    );
    if (!ok || !mounted) return;

    await context.read<BinProvider>().load();
    await context.read<IssueProvider>().load();
    await context.read<ImpactProvider>().load();
    context.read<RouteProvider>().rebuild(context.read<BinProvider>().bins);

    if (!mounted) return;
    Widget shell;
    switch (auth.currentUser!.role) {
      case UserRole.citizen:
        shell = const CitizenShell();
        break;
      case UserRole.collector:
        shell = const CollectorShell();
        break;
      case UserRole.admin:
        shell = const AdminShell();
        break;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => shell),
    );
  }

  void _fillDemo(UserRole role) {
    setState(() {
      _role = role;
      switch (role) {
        case UserRole.citizen:
          _email.text = 'citizen@ecosort.app';
          _password.text = 'citizen123';
          break;
        case UserRole.collector:
          _email.text = 'collector@ecosort.app';
          _password.text = 'collector123';
          break;
        case UserRole.admin:
          _email.text = 'admin@ecosort.app';
          _password.text = 'admin123';
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.forest, size: 56, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text(
              'Welcome to EcoSort',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mock mode — no Firebase key required.\nPick a role, then sign in.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 28),
            const Text('I am a…', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SegmentedButton<UserRole>(
              segments: const [
                ButtonSegment(
                  value: UserRole.citizen,
                  label: Text('Citizen'),
                  icon: Icon(Icons.person_outline),
                ),
                ButtonSegment(
                  value: UserRole.collector,
                  label: Text('Collector'),
                  icon: Icon(Icons.local_shipping_outlined),
                ),
                ButtonSegment(
                  value: UserRole.admin,
                  label: Text('Admin'),
                  icon: Icon(Icons.admin_panel_settings_outlined),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (s) => _fillDemo(s.first),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(auth.error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: auth.isLoading ? null : _submit,
              child: auth.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign in'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Demo accounts\n'
              'citizen@ecosort.app / citizen123\n'
              'collector@ecosort.app / collector123\n'
              'admin@ecosort.app / admin123',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
