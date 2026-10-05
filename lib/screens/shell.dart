import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'map_screen.dart';
import 'settings_screens.dart';

class Shell extends StatefulWidget {
  final int index;
  const Shell({super.key, this.index = 0});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late int _i = widget.index;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: IndexedStack(index: _i, children: const [HomeScreen(), HistoryScreen(), MapScreen(), SettingsScreen()])),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _i, onDestinationSelected: (i) => setState(() => _i = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history), label: 'History'),
            NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: 'Map'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      );
}
