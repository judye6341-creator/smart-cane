import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import '../widgets/sensor_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _tab = 0;
  DateTime _date = DateTime.now();

  Future<void> _pick() async {
    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2025), lastDate: DateTime.now());
    if (d != null) setState(() => _date = d);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    double avg(List<double> v) => v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
      const Text('Sensor History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
      const SizedBox(height: 14),
      SCard(onTap: _pick, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [
        const Icon(Icons.calendar_today_outlined, size: 20), const SizedBox(width: 12),
        Expanded(child: Text(dateLabel(_date), style: const TextStyle(fontWeight: FontWeight.w500))), const Icon(Icons.chevron_right),
      ])),
      const SizedBox(height: 14),
      SegmentedButton<int>(
        showSelectedIcon: false, selected: {_tab}, onSelectionChanged: (v) => setState(() => _tab = v.first),
        segments: [
          const ButtonSegment(value: 0, label: Text('Vitals')), const ButtonSegment(value: 1, label: Text('Activity')),
          ButtonSegment(value: 2, label: Text('Events${s.events.isEmpty ? '' : ' (${s.events.length})'}')),
        ],
      ),
      const SizedBox(height: 16),
      if (_tab == 0) ...[
        _ChartCard('Heart Rate (BPM)', Icons.favorite, C.pink, '${avg(s.hrSeries).round()} avg', s.hrSeries, 40, 160),
        const SizedBox(height: 14),
        _ChartCard('SpO₂ (%)', Icons.water_drop, C.purple, '${avg(s.spoSeries).round()} avg', s.spoSeries, 80, 100),
      ],
      if (_tab == 1) ...[
        for (final r in [
          ('Walking', 'Normal', Icons.directions_walk, C.lightGreen, C.greenDark, '09:00 – 10:30'),
          ('Standing', 'Normal', Icons.accessibility_new, C.softBlue, C.blue, '10:30 – 10:45'),
          ('Sitting', 'Normal', Icons.chair_alt, C.lightPurple, C.purple, '10:45 – 12:00'),
          for (final e in s.events) ('Possible Fall', 'ALERT · ${(e.fallProbability * 100).round()}%', Icons.warning_rounded, C.lightRed, C.red, '${e.timestamp.hour.toString().padLeft(2, '0')}:${e.timestamp.minute.toString().padLeft(2, '0')}'),
        ])
          Padding(padding: const EdgeInsets.only(bottom: 10), child: SCard(color: r.$4, borderColor: Colors.transparent, child: Row(children: [
            Icon(r.$3, color: r.$5), const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w600)), Text(r.$2, style: const TextStyle(color: C.text2, fontSize: 12))])),
            Text(r.$6, style: const TextStyle(color: C.text2, fontSize: 12)),
          ]))),
      ],
      if (_tab == 2)
        s.events.isEmpty
            ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No emergency events recorded.\nTrigger one from Home → Demo mode.', textAlign: TextAlign.center, style: TextStyle(color: C.text2))))
            : Column(children: [
                for (final e in s.events)
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: SCard(color: C.lightRed, borderColor: C.pink, onTap: () => Navigator.pushNamed(context, '/emergency'), child: Row(children: [
                    const Icon(Icons.warning_rounded, color: C.red, size: 32), const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('CRITICAL — Possible fall', style: TextStyle(fontWeight: FontWeight.w700, color: C.red)),
                      Text('Fall ${(e.fallProbability * 100).round()}% · HR ${e.heartRate} BPM · ${ago(e.timestamp)}', style: const TextStyle(color: C.text2, fontSize: 12)),
                    ])),
                    const Icon(Icons.chevron_right),
                  ]))),
              ]),
    ]);
  }
}

class _ChartCard extends StatelessWidget {
  final String title, avg;
  final IconData icon;
  final Color color;
  final List<double> data;
  final double min, max;
  const _ChartCard(this.title, this.icon, this.color, this.avg, this.data, this.min, this.max);
  @override
  Widget build(BuildContext context) => SCard(
        semantic: '$title, $avg',
        child: Column(children: [
          Row(children: [
            Icon(icon, color: color, size: 20), const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(avg, style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 14),
          SensorChart(values: List.of(data), min: min, max: max, color: color == C.pink ? const Color(0xFFE88C9B) : color),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [for (final t in ['9:00', '10:00', '11:00', '12:00']) Text(t, style: const TextStyle(color: C.text2, fontSize: 11))]),
        ]),
      );
}
