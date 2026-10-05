import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import '../widgets/vital_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String get _greeting {
    final h = DateTime.now().hour;
    return h < 12 ? 'Good morning' : h < 18 ? 'Good afternoon' : 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final a = s.current;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
          Row(children: [
            Expanded(child: Text('$_greeting,\n${s.profile.name.split(' ').first}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.25))),
            IconButton(tooltip: 'Notifications', onPressed: () => Navigator.pushNamed(context, '/notifications'), icon: const Icon(Icons.notifications_none_rounded)),
            Semantics(label: 'Profile', button: true, child: GestureDetector(onTap: () => Navigator.pushNamed(context, '/profile'), child: const CircleAvatar(backgroundColor: C.softBlue, child: Icon(Icons.person, color: C.blue)))),
          ]),
          const SizedBox(height: 16),
          _StatusCard(a: a, onTap: () => Navigator.pushNamed(context, a.risk == Risk.normal ? '/device' : '/emergency')),
          const SectionTitle('Live Vitals'),
          LayoutBuilder(builder: (context, c) {
            final w = (c.maxWidth - 12) / 2;
            final hrBad = a.heartRate > 110, spoBad = a.spo2 < 94;
            return Wrap(spacing: 12, runSpacing: 12, children: [
              SizedBox(width: w, child: VitalCard(icon: Icons.favorite, label: 'Heart Rate', value: '${a.heartRate}', unit: 'BPM', status: hrBad ? 'High ▲' : 'Normal', color: C.pink, bg: C.lightPink)),
              SizedBox(width: w, child: VitalCard(icon: Icons.water_drop, label: 'SpO₂', value: '${a.spo2}', unit: '%', status: spoBad ? 'Low ▼' : 'Normal', color: C.purple, bg: C.lightPurple)),
              SizedBox(width: w, child: VitalCard(icon: Icons.directions_walk, label: 'Activity', value: a.activity, status: a.risk == Risk.normal ? 'Normal' : 'Needs attention', color: C.greenDark, bg: C.lightGreen)),
              SizedBox(width: w, child: VitalCard(icon: Icons.battery_5_bar, label: 'Battery', value: '${s.device.battery}', unit: '%', status: 'Connected', color: C.greenDark, bg: C.lightGreen, onTap: () => Navigator.pushNamed(context, '/device'))),
            ]);
          }),
          SectionTitle('Recent Activity', action: 'View all', onAction: () => Navigator.pushNamed(context, '/history')),
          for (final n in s.activity.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SCard(
                color: n.title.contains('fall') ? C.lightRed : C.lightGreen, borderColor: Colors.transparent,
                child: Row(children: [
                  Icon(n.title.contains('fall') ? Icons.warning_rounded : Icons.shield_outlined, color: n.title.contains('fall') ? C.red : C.greenDark, size: 32),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${n.body} · ${ago(n.time)}', style: const TextStyle(color: C.text2, fontSize: 12)),
                  ])),
                ]),
              ),
            ),
          const SectionTitle('Demo mode'),
          const _DemoPanel(),
        ]),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final RiskAssessment a;
  final VoidCallback onTap;
  const _StatusCard({required this.a, required this.onTap});
  @override
  Widget build(BuildContext context) {
    late String title, sub; late IconData icon; late Color fg, bg;
    switch (a.risk) {
      case Risk.normal: title = 'All Good'; sub = 'No alerts at the moment · Connected'; icon = Icons.check_circle; fg = C.greenDark; bg = C.lightGreen;
      case Risk.caution: title = '🟡 Activity requires attention'; sub = 'Risk ${a.percent}% · Keep an eye on Judy'; icon = Icons.info_rounded; fg = const Color(0xFFB8941F); bg = C.lightYellow;
      case Risk.high: title = '🟠 High Risk Detected'; sub = 'Risk ${a.percent}% · Check on the user'; icon = Icons.error_rounded; fg = const Color(0xFFD27B2C); bg = C.lightOrange;
      case Risk.critical: title = '🔴 CRITICAL — Emergency Alert'; sub = 'Possible fall · Tap for details'; icon = Icons.warning_rounded; fg = C.red; bg = C.lightRed;
    }
    return SCard(
      onTap: onTap, color: bg, borderColor: Colors.transparent, semantic: '$title. $sub',
      child: Row(children: [
        Icon(icon, color: fg, size: 38),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: fg == C.greenDark ? C.text : fg)),
          Text(sub, style: const TextStyle(color: C.text2, fontSize: 13)),
        ])),
        const Icon(Icons.chevron_right, color: C.text2),
      ]),
    );
  }
}

class _DemoPanel extends StatelessWidget {
  const _DemoPanel();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    const labels = {Scenario.normal: 'Normal', Scenario.walking: 'Walking', Scenario.caution: 'Caution', Scenario.high: 'High Risk', Scenario.emergency: 'Emergency'};
    return SCard(
      color: C.veryLight,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Simulate smart-cane AI results (mock data)', style: TextStyle(color: C.text2, fontSize: 12)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in labels.entries)
            ChoiceChip(
              label: Text(e.value), selected: s.scenario == e.key,
              selectedColor: e.key == Scenario.emergency ? C.lightRed : C.softBlue,
              onSelected: (_) => s.setScenario(e.key),
            ),
        ]),
      ]),
    );
  }
}
