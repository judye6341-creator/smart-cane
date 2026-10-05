import 'package:flutter/material.dart';
import '../screens/auth_screens.dart';
import '../screens/shell.dart';
import '../screens/emergency_screen.dart';
import '../screens/contacts_screen.dart';
import '../screens/settings_screens.dart';

class Routes {
  static Route<dynamic> generate(RouteSettings s) {
    Widget page;
    switch (s.name) {
      case '/login': page = const AuthScreen(); break;
      case '/signup': page = const AuthScreen(signup: true); break;
      case '/home': page = const Shell(index: 0); break;
      case '/history': page = const Shell(index: 1); break;
      case '/map': page = const Shell(index: 2); break;
      case '/settings': page = const Shell(index: 3); break;
      case '/emergency': page = const EmergencyScreen(); break;
      case '/contacts': page = const ContactsScreen(); break;
      case '/profile': page = const ProfileScreen(); break;
      case '/device': page = const DeviceScreen(); break;
      case '/notifications': page = const NotificationSettingsScreen(); break;
      default: page = const WelcomeScreen();
    }
    return PageRouteBuilder(
      settings: s, pageBuilder: (_, __, ___) => page, transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    );
  }
}
