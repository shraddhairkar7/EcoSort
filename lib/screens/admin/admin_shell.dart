import 'package:flutter/material.dart';

import 'package:ecosort/screens/admin/admin_dashboard_screen.dart';
import 'package:ecosort/screens/admin/analytics_screen.dart';
import 'package:ecosort/screens/admin/manage_bins_screen.dart';
import 'package:ecosort/screens/admin/review_reports_screen.dart';
import 'package:ecosort/screens/citizen/citizen_profile_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      AdminDashboardScreen(),
      AnalyticsScreen(),
      ManageBinsScreen(),
      ReviewReportsScreen(),
      CitizenProfileScreen(),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.delete_outline), label: 'Bins'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
