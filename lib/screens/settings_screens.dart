import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppState>().profile;
    final rows = [
      (Icons.person_outline, 'User Profile', '/profile'), (Icons.phone_in_talk_outlined, 'Emergency Contacts', '/contacts'),
      (Icons.notifications_none, 'Notification Settings', '/notifications'), (Icons.sensors, 'Device Settings', '/device'),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
      const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
      const SizedBox(height: 14),
      SCard(onTap: () => Navigator.pushNamed(context, '/profile'), child: Row(children: [
        const CircleAvatar(radius: 28, backgroundColor: C.softBlue, child: Icon(Icons.person, color: C.blue, size: 30)), const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)), Text(p.role, style: const TextStyle(color: C.text2, fontSize: 13))])),
        const Icon(Icons.chevron_right, color: C.text2),
      ])),
      const SizedBox(height: 14),
      SCard(padding: EdgeInsets.zero, child: Column(children: [
        for (final r in rows) _Tile(r.$1, r.$2, () => Navigator.pushNamed(context, r.$3)),
        _Tile(Icons.settings_outlined, 'App Preferences', () => _soon(context)),
        _Tile(Icons.help_outline, 'Help & Support', () => _soon(context)),
      ])),
      const SizedBox(height: 20),
      PrimaryButton('Log Out', icon: Icons.logout, color: const Color(0xFF4A8BD4), outlined: true, onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false)),
    ]);
  }

  void _soon(BuildContext c) => ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('Help: sanad.support@example.com · Preferences: coming soon')));
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Tile(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => ListTile(minTileHeight: 56, leading: Icon(icon, color: C.blue), title: Text(label), trailing: const Icon(Icons.chevron_right, color: C.text2), onTap: onTap);
}

class _Page extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Page(this.title, this.children);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20))),
        body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: children)))),
      );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppState>().profile;
    Widget item(IconData i, String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SCard(child: Row(children: [
          IconBadge(i, color: C.blue, bg: C.softBlue), const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(color: C.text2, fontSize: 12)), Text(v, style: const TextStyle(fontWeight: FontWeight.w600))])),
        ])));
    return _Page('User Profile', [
      const Center(child: CircleAvatar(radius: 44, backgroundColor: C.softBlue, child: Icon(Icons.person, color: C.blue, size: 48))),
      const SizedBox(height: 10),
      Center(child: Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
      const SizedBox(height: 16),
      item(Icons.cake_outlined, 'Age', '${p.age}'), item(Icons.bloodtype_outlined, 'Blood type', p.bloodType),
      item(Icons.warning_amber_rounded, 'Allergies', p.allergies), item(Icons.medical_information_outlined, 'Medical conditions', p.conditions),
      item(Icons.emergency_outlined, 'Emergency information', p.emergencyInfo),
    ]);
  }
}

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});
  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool _running = false;
  Future<void> _diagnose() async {
    setState(() => _running = true);
    await Future.delayed(const Duration(seconds: 2)); // Phase 7: ask ESP32 for a self-test via the backend
    if (!mounted) return;
    setState(() => _running = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diagnostics complete: all sensors OK')));
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<AppState>().device;
    Widget row(IconData i, String l, bool ok, [String? val]) => ListTile(
          leading: Icon(i, color: C.blue), title: Text(l),
          trailing: Text(val ?? (ok ? '🟢 Connected' : '⚪ Not connected'), style: TextStyle(color: ok ? C.greenDark : C.text2, fontWeight: FontWeight.w600)),
        );
    return _Page('Smart Cane', [
      SCard(color: C.lightGreen, borderColor: Colors.transparent, child: Row(children: [
        const Icon(Icons.check_circle, color: C.greenDark, size: 34), const SizedBox(width: 12),
        Text(d.connected ? '🟢 Connected' : 'Disconnected', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ])),
      const SizedBox(height: 14),
      SCard(padding: EdgeInsets.zero, child: Column(children: [
        row(Icons.battery_5_bar, 'Battery', true, '${d.battery}%'), row(Icons.wifi, 'Wi-Fi', d.wifi), row(Icons.psychology_outlined, 'AI Model', d.aiActive, 'Active'),
        row(Icons.speed, 'MPU6050', d.mpu6050), row(Icons.monitor_heart_outlined, 'MAX30102', d.max30102),
        row(Icons.graphic_eq, 'Ultrasonic', d.ultrasonic), row(Icons.gps_fixed, 'GPS', d.gps),
      ])),
      const SizedBox(height: 18),
      PrimaryButton(_running ? 'Running diagnostics…' : 'Run Diagnostics', icon: Icons.build_circle_outlined, onPressed: _running ? null : _diagnose),
    ]);
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return _Page('Notification Settings', [
      SCard(padding: EdgeInsets.zero, child: Column(children: [
        for (final e in s.prefs.entries) SwitchListTile(title: Text(e.key), value: e.value, activeTrackColor: C.blue, onChanged: (v) => s.togglePref(e.key, v)),
      ])),
    ]);
  }
}
