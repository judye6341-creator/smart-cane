import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/models.dart';

/// Phase 3 simulates a push with an in-app banner. Phase 5: replace with
/// firebase_messaging + flutter_local_notifications; onTap -> navKey.pushNamed('/emergency').
class NotificationService {
  static void showEmergency(GlobalKey<ScaffoldMessengerState> msg, GlobalKey<NavigatorState> nav, RiskAssessment a) {
    final m = msg.currentState;
    if (m == null) return;
    m.hideCurrentMaterialBanner();
    m.showMaterialBanner(MaterialBanner(
      backgroundColor: C.lightRed,
      leading: const Icon(Icons.warning_rounded, color: C.red),
      content: Text('🚨 Emergency Alert\nPossible fall detected · Heart Rate: ${a.heartRate} BPM · Fall Probability: ${a.percent}%',
          style: const TextStyle(color: C.text, fontWeight: FontWeight.w500)),
      actions: [
        TextButton(onPressed: () { m.hideCurrentMaterialBanner(); nav.currentState?.pushNamed('/emergency'); }, child: const Text('Open')),
        TextButton(onPressed: m.hideCurrentMaterialBanner, child: const Text('Dismiss')),
      ],
    ));
  }
}
