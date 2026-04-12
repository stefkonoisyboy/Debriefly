import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/providers.dart';
import 'screens/dashboard_screen.dart';
import 'screens/debrief_deep_link_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/debrief/:id',
      builder: (context, state) =>
          DebriefDeepLinkScreen(debriefId: state.pathParameters['id']!),
    ),
  ],
);

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DebriefProvider(),
      child: MaterialApp.router(
        title: 'Debriefly',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A1A2E)),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
