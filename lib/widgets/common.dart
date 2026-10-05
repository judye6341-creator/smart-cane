import 'package:flutter/material.dart';
import '../core/theme.dart';

class SCard extends StatelessWidget {
  final Widget child;
  final Color color, borderColor;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final String? semantic;
  const SCard({super.key, required this.child, this.color = Colors.white, this.borderColor = C.border, this.padding = const EdgeInsets.all(16), this.onTap, this.semantic});
  @override
  Widget build(BuildContext context) => Semantics(
        label: semantic, button: onTap != null,
        child: Material(
          color: color, clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: borderColor)),
          child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
        ),
      );
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final double size;
  const IconBadge(this.icon, {super.key, required this.color, required this.bg, this.size = 40});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, color: color, size: size * .5));
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;
  final bool outlined;
  final double height;
  const PrimaryButton(this.label, {super.key, this.onPressed, this.color = C.blue, this.icon, this.outlined = false, this.height = 52});
  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(28));
    final txt = Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
      Flexible(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
    ]);
    return SizedBox(
      width: double.infinity, height: height,
      child: outlined
          ? OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color), shape: shape), child: txt)
          : FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: shape, elevation: 0), child: txt),
    );
  }
}

class SanadLogo extends StatelessWidget {
  final double size;
  const SanadLogo({super.key, this.size = 90});
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Sanad logo',
        child: Stack(alignment: Alignment.center, children: [
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(colors: [C.blue, C.green]).createShader(r),
            child: Icon(Icons.favorite_rounded, size: size, color: Colors.white),
          ),
          Icon(Icons.monitor_heart_outlined, size: size * .5, color: Colors.white),
        ]),
      );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          if (action != null) TextButton(onPressed: onAction, child: Text(action!, style: const TextStyle(color: C.text2, fontSize: 13))),
        ]),
      );
}

String ago(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'Just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} hours ago';
  return '${d.inDays} days ago';
}

String dateLabel(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${m[d.month - 1]} ${d.day}, ${d.year}';
}
