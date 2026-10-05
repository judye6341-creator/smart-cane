import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

Future<void> callNumber(BuildContext context, String phone) async {
  final ok = await launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(' ', ''))).catchError((_) => false);
  if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot place a call on this device. Number: $phone')));
}

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  late final AppState _s;

  @override
  void initState() {
    super.initState();
    _s = context.read<AppState>()..emergencyOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).hideCurrentMaterialBanner());
  }

  @override
  void dispose() { _s.emergencyOpen = false; _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final a = s.current;
    final crit = a.risk == Risk.critical;
    return Scaffold(
      backgroundColor: C.lightRed,
      appBar: AppBar(backgroundColor: C.lightRed, leading: IconButton(tooltip: 'Close', icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
              Center(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, child) => Container(
                    padding: EdgeInsets.all(8 + 8 * _pulse.value),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: C.red.withValues(alpha: .12 * (1 - _pulse.value) + .05)),
                    child: child,
                  ),
                  child: const IconBadge(Icons.warning_rounded, color: Colors.white, bg: C.red, size: 80),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Emergency Alert', textAlign: TextAlign.center, style: TextStyle(color: C.red, fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(crit ? 'Possible fall detected!' : 'Alert details (risk has changed)', textAlign: TextAlign.center, style: const TextStyle(color: C.red, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('The system has detected a potential fall and an abnormal heart rate.', textAlign: TextAlign.center, style: TextStyle(color: C.text2, height: 1.5)),
              const SizedBox(height: 20),
              SCard(
                borderColor: C.pink,
                child: Column(children: [
                  _Row(Icons.favorite, 'Heart Rate', '${a.heartRate} BPM', a.heartRate > 110 ? 'High' : 'Normal', C.red),
                  const Divider(height: 28, color: C.border),
                  _Row(Icons.directions_run, 'Fall Probability', '${a.percent}%', crit ? 'CRITICAL' : a.risk.name.toUpperCase(), C.red),
                  const Divider(height: 28, color: C.border),
                  _Row(Icons.location_on, 'Location', 'Lat $kLat, Long $kLng', '', C.red, onTap: () => Navigator.pushNamed(context, '/map'), link: 'View on Map'),
                ]),
              ),
              const SizedBox(height: 20),
              PrimaryButton('Call ${s.primary?.name ?? 'Caregiver'}', icon: Icons.phone, color: C.red, height: 56,
                  onPressed: s.primary == null ? null : () => callNumber(context, s.primary!.phone)),
              const SizedBox(height: 12),
              PrimaryButton('View Sensor Data', color: C.red, outlined: true, onPressed: () => Navigator.pushNamed(context, '/history')),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () { s.setScenario(Scenario.normal); Navigator.pop(context); },
                child: const Text("I'm safe — resolve alert", style: TextStyle(color: C.text2)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label, value, status, link;
  final Color color;
  final VoidCallback? onTap;
  const _Row(this.icon, this.label, this.value, this.status, this.color, {this.onTap, this.link = ''});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: C.text2, fontSize: 13)),
          Row(children: [
            Flexible(child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
            if (status.isNotEmpty) ...[const SizedBox(width: 10), Text('($status)', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13))],
          ]),
          if (link.isNotEmpty) InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(link, style: const TextStyle(color: Color(0xFF3F7FC4), fontWeight: FontWeight.w600)))),
        ])),
      ]);
}
