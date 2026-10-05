import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'providers/app_state.dart';
import 'services/data_service.dart';
import 'services/notification_service.dart';

final navKey = GlobalKey<NavigatorState>();
final msgKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  // Phase 4+: swap MockDataService() for FirebaseDataService() / ApiDataService().
  runApp(ChangeNotifierProvider(create: (_) => AppState(MockDataService()), child: const SanadApp()));
}

class SanadApp extends StatefulWidget {
  const SanadApp({super.key});
  @override
  State<SanadApp> createState() => _SanadAppState();
}

class _SanadAppState extends State<SanadApp> {
  late final AppState _s;
  @override
  void initState() {
    super.initState();
    _s = context.read<AppState>()..addListener(_check);
  }

  void _check() {
    if (!_s.pendingEmergency) return;
    _s.pendingEmergency = false;
    NotificationService.showEmergency(msgKey, navKey, _s.current);
    // Foreground demo: open the alert automatically if the caregiver hasn't tapped the banner.
    Future.delayed(const Duration(seconds: 2), () {
      if (!_s.emergencyOpen) navKey.currentState?.pushNamed('/emergency');
    });
  }

  @override
  void dispose() { _s.removeListener(_check); super.dispose(); }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Sanad', debugShowCheckedModeBanner: false, theme: buildTheme(),
        navigatorKey: navKey, scaffoldMessengerKey: msgKey,
        onGenerateRoute: Routes.generate, initialRoute: '/',
      );
}
