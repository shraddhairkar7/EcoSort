import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecosort/config/app_config.dart';
import 'package:ecosort/providers/auth_provider.dart';
import 'package:ecosort/providers/bin_provider.dart';
import 'package:ecosort/providers/impact_provider.dart';
import 'package:ecosort/providers/issue_provider.dart';
import 'package:ecosort/providers/route_provider.dart';
import 'package:ecosort/screens/auth/splash_screen.dart';
import 'package:ecosort/services/data_service.dart';
import 'package:ecosort/services/firebase_data_service.dart';
import 'package:ecosort/services/service_locator.dart';
import 'package:ecosort/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is opt-in. Mock mode never touches the network.
  if (AppConfig.useFirebase) {
    await FirebaseDataService.initialize();
  }

  final data = createDataService();
  runApp(EcoSortApp(data: data));
}

class EcoSortApp extends StatelessWidget {
  const EcoSortApp({super.key, required this.data});

  final DataService data;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DataService>.value(value: data),
        ChangeNotifierProvider(create: (_) => AuthProvider(data)),
        ChangeNotifierProvider(create: (_) => BinProvider(data)),
        ChangeNotifierProvider(create: (_) => IssueProvider(data)),
        ChangeNotifierProvider(create: (_) => ImpactProvider(data)),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
      ],
      child: MaterialApp(
        title: 'EcoSort',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}
