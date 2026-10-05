import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';

/// Placeholder map (no API key needed). Phase 9: swap _FakeMap for google_maps_flutter / flutter_map
/// fed by SensorReading.latitude/longitude.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$kLat,$kLng');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Maps on this device.')));
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
        const Text('User Location', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        Semantics(
          label: 'Map showing the user at latitude $kLat, longitude $kLng',
          child: ClipRRect(borderRadius: BorderRadius.circular(20), child: SizedBox(height: 320, child: Stack(alignment: Alignment.center, children: [
            Positioned.fill(child: CustomPaint(painter: _FakeMap())),
            Container(width: 110, height: 110, decoration: BoxDecoration(color: C.blue.withValues(alpha: .25), shape: BoxShape.circle)),
            const Icon(Icons.location_on, color: Color(0xFF4A8BD4), size: 48),
          ]))),
        ),
        const SizedBox(height: 14),
        SCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.location_on, color: C.blue), SizedBox(width: 8), Text('Current Location', style: TextStyle(fontWeight: FontWeight.w600))]),
          const SizedBox(height: 6),
          const Text('Lat $kLat, Long $kLng', style: TextStyle(fontSize: 15)),
          const Text('Last updated: 2 min ago', style: TextStyle(color: C.text2, fontSize: 12)),
          const SizedBox(height: 14),
          PrimaryButton('Open in Maps', icon: Icons.map_outlined, color: const Color(0xFF4A8BD4), outlined: true, height: 48, onPressed: () => _open(context)),
        ])),
      ]);
}

class _FakeMap extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFEAF1F7));
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width * .72, s.height * .55, s.width * .22, s.height * .3), const Radius.circular(12)), Paint()..color = C.lightGreen);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width * .05, s.height * .1, s.width * .2, s.height * .2), const Radius.circular(12)), Paint()..color = C.lightGreen);
    final road = Paint()..color = Colors.white..strokeWidth = 12..strokeCap = StrokeCap.round;
    final thin = Paint()..color = Colors.white..strokeWidth = 5;
    for (var i = 1; i < 5; i++) {
      c.drawLine(Offset(0, s.height * i / 5 + i * 6), Offset(s.width, s.height * i / 5 - i * 10), i.isEven ? road : thin);
      c.drawLine(Offset(s.width * i / 5, 0), Offset(s.width * i / 5 + 30, s.height), i.isOdd ? road : thin);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
