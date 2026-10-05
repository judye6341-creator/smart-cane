import 'package:flutter/material.dart';
import '../core/theme.dart';

class SensorChart extends StatelessWidget {
  final List<double> values;
  final double min, max;
  final Color color;
  final double height;
  const SensorChart({super.key, required this.values, required this.min, required this.max, this.color = C.blue, this.height = 130});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1), duration: const Duration(milliseconds: 600), key: ValueKey(values.length),
        builder: (_, t, __) => SizedBox(height: height, width: double.infinity, child: CustomPaint(painter: _P(values, min, max, color, t))),
      );
}

class _P extends CustomPainter {
  final List<double> v;
  final double mn, mx, t;
  final Color c;
  _P(this.v, this.mn, this.mx, this.c, this.t);
  @override
  void paint(Canvas canvas, Size s) {
    final grid = Paint()..color = C.border..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = s.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(s.width, y), grid);
    }
    if (v.length < 2) return;
    final pts = <Offset>[
      for (var i = 0; i < v.length; i++) Offset(s.width * i / (v.length - 1), s.height - ((v[i] - mn) / (mx - mn)).clamp(0.0, 1.0) * s.height * t),
    ];
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) { line.lineTo(p.dx, p.dy); }
    final fill = Path.from(line)..lineTo(s.width, s.height)..lineTo(0, s.height)..close();
    canvas.drawPath(fill, Paint()..color = c.withValues(alpha: .15));
    canvas.drawPath(line, Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeJoin = StrokeJoin.round);
  }
  @override
  bool shouldRepaint(_P o) => o.v != v || o.t != t;
}
