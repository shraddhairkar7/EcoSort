import 'package:flutter/material.dart';

import 'package:ecosort/screens/citizen/citizen_profile_screen.dart';
import 'package:ecosort/screens/collector/collector_issues_screen.dart';
import 'package:ecosort/screens/collector/today_route_screen.dart';

class CollectorShell extends StatefulWidget {
  const CollectorShell({super.key});

  @override
  State<CollectorShell> createState() => _CollectorShellState();
}

class _CollectorShellState extends State<CollectorShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      TodayRouteScreen(),
      CollectorIssuesScreen(),
      CitizenProfileScreen(),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_outlined),
            label: 'Issues',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
