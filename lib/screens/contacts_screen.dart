import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/common.dart';
import 'emergency_screen.dart' show callNumber;

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  Future<void> _edit(BuildContext context, [EmergencyContact? c]) async {
    final name = TextEditingController(text: c?.name), rel = TextEditingController(text: c?.relation), ph = TextEditingController(text: c?.phone);
    final s = context.read<AppState>();
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(c == null ? 'Add contact' : 'Edit contact', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          TextField(controller: name, decoration: const InputDecoration(hintText: 'Name')), const SizedBox(height: 10),
          TextField(controller: rel, decoration: const InputDecoration(hintText: 'Relationship')), const SizedBox(height: 10),
          TextField(controller: ph, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone number')), const SizedBox(height: 16),
          PrimaryButton('Save', onPressed: () {
            if (name.text.trim().isEmpty || ph.text.trim().isEmpty) return;
            s.saveContact(EmergencyContact(id: c?.id ?? DateTime.now().microsecondsSinceEpoch.toString(), name: name.text.trim(), relation: rel.text.trim(), phone: ph.text.trim(), primary: c?.primary ?? s.contacts.isEmpty));
            Navigator.pop(ctx);
          }),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        actions: [IconButton(tooltip: 'Add contact', icon: const Icon(Icons.add), onPressed: () => _edit(context))],
      ),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          for (final c in s.contacts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SCard(
                onTap: () => _edit(context, c), semantic: '${c.name}, ${c.relation}, ${c.phone}',
                child: Row(children: [
                  const CircleAvatar(backgroundColor: C.softBlue, child: Icon(Icons.person, color: C.blue)), const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('${c.relation} · ${c.phone}', style: const TextStyle(color: C.text2, fontSize: 12)),
                    if (c.primary) Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: C.lightGreen, borderRadius: BorderRadius.circular(8)), child: const Text('Primary', style: TextStyle(color: C.greenDark, fontSize: 11, fontWeight: FontWeight.w600))),
                  ])),
                  IconButton.filledTonal(tooltip: 'Call ${c.name}', onPressed: () => callNumber(context, c.phone), icon: const Icon(Icons.phone, color: C.blue)),
                  PopupMenuButton<String>(
                    onSelected: (v) => v == 'primary' ? s.setPrimary(c.id) : s.deleteContact(c.id),
                    itemBuilder: (_) => [if (!c.primary) const PopupMenuItem(value: 'primary', child: Text('Set as primary')), const PopupMenuItem(value: 'delete', child: Text('Delete'))],
                  ),
                ]),
              ),
            ),
          SCard(color: C.veryLight, child: const Row(children: [
            Icon(Icons.shield_outlined, color: C.blue), SizedBox(width: 12),
            Expanded(child: Text('In case of emergency, the app will alert the primary contact with the user’s location and health data.', style: TextStyle(color: C.text2, fontSize: 12))),
          ])),
        ]),
      ),
    );
  }
}
