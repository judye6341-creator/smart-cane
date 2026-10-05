import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/data_service.dart';

const kLat = 31.0419, kLng = 31.3789;

class AppState extends ChangeNotifier {
  final DataService service;
  late final StreamSubscription<RiskAssessment> _sub;
  AppState(this.service) {
    _sub = service.assessments.listen(_onData);
    service.start();
  }

  RiskAssessment current = RiskAssessment(fallProbability: 0.04, heartRate: 78, spo2: 98, activity: 'Walking', timestamp: DateTime.now());
  Scenario scenario = Scenario.normal;
  bool pendingEmergency = false, emergencyOpen = false;
  final List<double> hrSeries = [74, 80, 77, 82, 79, 76, 81, 78, 75, 80, 78, 77];
  final List<double> spoSeries = [98, 98, 97, 98, 99, 98, 98, 97, 98, 98, 99, 98];
  final List<EmergencyEvent> events = [];
  final List<NotificationModel> activity = [
    NotificationModel('System normal', 'All sensors reporting', DateTime.now().subtract(const Duration(hours: 2))),
    NotificationModel('Walking detected', 'Normal activity', DateTime.now().subtract(const Duration(minutes: 35))),
  ];
  final prefs = <String, bool>{'Emergency alerts': true, 'Fall detection alerts': true, 'Abnormal heart-rate alerts': true, 'Low battery alerts': true, 'Device disconnected alerts': true};
  final profile = const UserProfile(name: 'Judy Elatr', role: 'Caregiver', age: 72, bloodType: 'O+', allergies: 'Penicillin', conditions: 'Type 2 diabetes, hypertension', emergencyInfo: 'Takes insulin daily. Uses a cane for balance.');
  final List<EmergencyContact> contacts = [
    const EmergencyContact(id: '1', name: 'Mom', relation: 'Mother', phone: '+20 10 1234 5678', primary: true),
    const EmergencyContact(id: '2', name: 'Dad', relation: 'Father', phone: '+20 10 9876 5432'),
    const EmergencyContact(id: '3', name: 'Dr. Ahmed', relation: 'Endocrinologist', phone: '+20 12 3456 7890'),
    const EmergencyContact(id: '4', name: 'Family Friend', relation: 'Friend', phone: '+20 11 2233 4455'),
  ];

  EmergencyContact? get primary => contacts.where((c) => c.primary).firstOrNull ?? contacts.firstOrNull;
  DeviceStatus get device => service.device;

  void _onData(RiskAssessment a) {
    final prev = current.risk;
    current = a;
    hrSeries.add(a.heartRate.toDouble());
    spoSeries.add(a.spo2.toDouble());
    if (hrSeries.length > 24) { hrSeries.removeAt(0); spoSeries.removeAt(0); }
    if (a.risk == Risk.critical && prev != Risk.critical) {
      events.insert(0, EmergencyEvent(id: '${a.timestamp.millisecondsSinceEpoch}', timestamp: a.timestamp, fallProbability: a.fallProbability, heartRate: a.heartRate, lat: kLat, lng: kLng));
      activity.insert(0, NotificationModel('Possible fall detected', 'Fall probability ${a.percent}%', a.timestamp));
      pendingEmergency = true;
    }
    notifyListeners();
  }

  void setScenario(Scenario s) { scenario = s; service.simulate(s); }
  void togglePref(String k, bool v) { prefs[k] = v; notifyListeners(); }

  void saveContact(EmergencyContact c) {
    final i = contacts.indexWhere((x) => x.id == c.id);
    i >= 0 ? contacts[i] = c : contacts.add(c);
    if (c.primary) { setPrimary(c.id); } else { notifyListeners(); }
  }
  void deleteContact(String id) { contacts.removeWhere((c) => c.id == id); notifyListeners(); }
  void setPrimary(String id) {
    for (var i = 0; i < contacts.length; i++) { contacts[i] = contacts[i].copyWith(primary: contacts[i].id == id); }
    notifyListeners();
  }

  @override
  void dispose() { _sub.cancel(); service.dispose(); super.dispose(); }
}
