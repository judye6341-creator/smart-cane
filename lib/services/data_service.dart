import 'dart:async';
import 'dart:math';
import '../models/models.dart';

/// UI depends ONLY on this interface. Phase 4+: write FirebaseDataService / ApiDataService
/// that implement it (Firestore snapshots / MQTT-bridge / FCM) and swap it in main.dart.
abstract class DataService {
  Stream<RiskAssessment> get assessments;
  DeviceStatus get device;
  void start();
  void simulate(Scenario s) {} // demo-only; real services ignore it
  void dispose();
}

class MockDataService implements DataService {
  final _c = StreamController<RiskAssessment>.broadcast();
  final _r = Random();
  Timer? _t;
  Scenario _s = Scenario.normal;

  @override
  Stream<RiskAssessment> get assessments => _c.stream;
  @override
  DeviceStatus get device => const DeviceStatus();

  @override
  void start() {
    _t = Timer.periodic(const Duration(seconds: 3), (_) => _c.add(_make()));
    Future.microtask(() => _c.add(_make()));
  }

  @override
  void simulate(Scenario s) {
    _s = s;
    _c.add(_make());
  }

  RiskAssessment _make() {
    int j(int n) => _r.nextInt(n * 2 + 1) - n;
    final now = DateTime.now();
    switch (_s) {
      case Scenario.normal:
        return RiskAssessment(fallProbability: 0.04, heartRate: 78 + j(2), spo2: 98, activity: 'Walking', timestamp: now);
      case Scenario.walking:
        return RiskAssessment(fallProbability: 0.08, heartRate: 94 + j(3), spo2: 97, activity: 'Walking fast', timestamp: now);
      case Scenario.caution:
        return RiskAssessment(fallProbability: 0.45, heartRate: 106 + j(3), spo2: 95, activity: 'Unsteady', timestamp: now);
      case Scenario.high:
        return RiskAssessment(fallProbability: 0.72, heartRate: 120 + j(3), spo2: 92, activity: 'Stumbling', timestamp: now);
      case Scenario.emergency:
        return RiskAssessment(fallProbability: 0.94, heartRate: 138, spo2: 89, activity: 'Possible Fall', timestamp: now);
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.close();
  }
}
