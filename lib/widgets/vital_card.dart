import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'common.dart';

class VitalCard extends StatelessWidget {
  final IconData icon;
  final String label, value, unit, status;
  final Color color, bg;
  final VoidCallback? onTap;
  const VitalCard({super.key, required this.icon, required this.label, required this.value, this.unit = '', required this.status, required this.color, required this.bg, this.onTap});
  @override
  Widget build(BuildContext context) => SCard(
        onTap: onTap, semantic: '$label $value $unit, $status',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconBadge(icon, color: color, bg: bg, size: 38),
            const SizedBox(width: 10),
            Flexible(child: Text(label, style: const TextStyle(color: C.text2, fontSize: 13))),
          ]),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text.rich(key: ValueKey(value), TextSpan(children: [
              TextSpan(text: value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              if (unit.isNotEmpty) TextSpan(text: ' $unit', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ])),
          ),
          const SizedBox(height: 4),
          Text(status, style: TextStyle(color: color == C.pink ? C.red : color, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      );
}
