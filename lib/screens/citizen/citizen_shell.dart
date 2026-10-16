import 'package:flutter/material.dart';

import 'package:ecosort/screens/citizen/citizen_home_screen.dart';
import 'package:ecosort/screens/citizen/citizen_profile_screen.dart';
import 'package:ecosort/screens/citizen/my_impact_screen.dart';
import 'package:ecosort/screens/citizen/report_issue_screen.dart';
import 'package:ecosort/screens/citizen/waste_sorting_screen.dart';

class CitizenShell extends StatefulWidget {
  const CitizenShell({super.key});

  @override
  State<CitizenShell> createState() => _CitizenShellState();
}

class _CitizenShellState extends State<CitizenShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      CitizenHomeScreen(),
      WasteSortingScreen(),
      ReportIssueScreen(),
      MyImpactScreen(),
      CitizenProfileScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Bins'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Sort'),
          NavigationDestination(icon: Icon(Icons.report_outlined), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: 'Impact'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
