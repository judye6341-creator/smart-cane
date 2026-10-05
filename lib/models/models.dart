enum Risk { normal, caution, high, critical }
enum Scenario { normal, walking, caution, high, emergency }

class RiskAssessment {
  final double fallProbability; // 0..1, produced by the AI (backend/ESP32), NOT the phone
  final int heartRate, spo2;
  final String activity;
  final DateTime timestamp;
  const RiskAssessment({required this.fallProbability, required this.heartRate, required this.spo2, required this.activity, required this.timestamp});

  Risk get risk => fallProbability > 0.8 ? Risk.critical : fallProbability >= 0.6 ? Risk.high : fallProbability >= 0.3 ? Risk.caution : Risk.normal;
  int get percent => (fallProbability * 100).round();

  factory RiskAssessment.fromJson(Map<String, dynamic> j) => RiskAssessment(
        fallProbability: (j['fall_probability'] as num).toDouble(), heartRate: j['heart_rate'] as int,
        spo2: (j['spo2'] ?? 97) as int, activity: (j['activity'] ?? 'Unknown') as String,
        timestamp: DateTime.tryParse('${j['timestamp']}') ?? DateTime.now());
}

class SensorReading {
  final DateTime timestamp;
  final double ax, ay, az, gx, gy, gz, distance;
  final int heartRate, spo2;
  final double? latitude, longitude;
  const SensorReading({required this.timestamp, this.ax = 0, this.ay = 0, this.az = 0, this.gx = 0, this.gy = 0, this.gz = 0,
      required this.heartRate, required this.spo2, this.distance = 0, this.latitude, this.longitude});
}

class EmergencyEvent {
  final String id;
  final DateTime timestamp;
  final double fallProbability;
  final int heartRate;
  final double lat, lng;
  const EmergencyEvent({required this.id, required this.timestamp, required this.fallProbability, required this.heartRate, required this.lat, required this.lng});
}

class EmergencyContact {
  final String id, name, relation, phone;
  final bool primary;
  const EmergencyContact({required this.id, required this.name, required this.relation, required this.phone, this.primary = false});
  EmergencyContact copyWith({String? name, String? relation, String? phone, bool? primary}) => EmergencyContact(
      id: id, name: name ?? this.name, relation: relation ?? this.relation, phone: phone ?? this.phone, primary: primary ?? this.primary);
}

class UserProfile {
  final String name, role, bloodType, allergies, conditions, emergencyInfo;
  final int age;
  const UserProfile({required this.name, required this.role, required this.age, required this.bloodType, required this.allergies, required this.conditions, required this.emergencyInfo});
}

class DeviceStatus {
  final bool connected, wifi, aiActive, mpu6050, max30102, ultrasonic, gps;
  final int battery;
  const DeviceStatus({this.connected = true, this.wifi = true, this.aiActive = true, this.mpu6050 = true, this.max30102 = true, this.ultrasonic = true, this.gps = true, this.battery = 82});
}

class NotificationModel {
  final String title, body;
  final DateTime time;
  const NotificationModel(this.title, this.body, this.time);
}
