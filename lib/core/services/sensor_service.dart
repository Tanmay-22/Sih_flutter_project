import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';

class SensorService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  // Database references
  static final DatabaseReference _dataRef = _database.ref();
  
  // Get real-time sensor data
  static Stream<SensorData?> getSensorDataStream() {
    return _dataRef.onValue.map((event) {
      if (event.snapshot.exists) {
        try {
          final rawData = event.snapshot.value;
          print('Raw Firebase data: $rawData');
          final data = Map<String, dynamic>.from(rawData as Map);
          print('Parsed data: $data');
          return SensorData.fromFirebase(data);
        } catch (e) {
          print('Error parsing sensor data: $e');
          return null;
        }
      }
      return null;
    });
  }
  
  // Initialize sensor data structure
  static Future<void> initializeSensorData() async {
    try {
      final snapshot = await _dataRef.get();
      if (!snapshot.exists) {
        await _dataRef.set({
          'Sensors': {
            'DHT22': {'temperature': 0, 'humidity': 0},
            'LDR': 0,
            'MLX90614': 0,
            'MQ135': 0,
            'Moisture': 0,
            'pH': 0,
          },
          'Actuators': {
            'Relay': 'OFF',
          },
        });
      }
    } catch (e) {
      throw Exception('Failed to initialize sensor data: $e');
    }
  }
  
  // Get relay status
  static Stream<String> getRelayStatusStream() {
    return _dataRef.child('Actuators/Relay').onValue.map((event) {
      if (event.snapshot.exists) {
        return event.snapshot.value as String? ?? 'OFF';
      }
      return 'OFF';
    });
  }
  
  // Toggle relay
  static Future<void> toggleRelay(bool isOn) async {
    try {
      await _dataRef.child('Actuators/Relay').set(isOn ? 'ON' : 'OFF');
    } catch (e) {
      throw Exception('Failed to toggle relay: $e');
    }
  }
  
  // Update sensor data (for testing purposes)
  static Future<void> updateSensorData(SensorData sensorData) async {
    try {
      await _dataRef.update(sensorData.toFirebase());
    } catch (e) {
      throw Exception('Failed to update sensor data: $e');
    }
  }
  
  // Get sensor history (for future implementation)
  static Future<DatabaseEvent> getSensorHistory({int limit = 50}) async {
    try {
      return await _dataRef
          .orderByChild('timestamp')
          .limitToLast(limit)
          .once();
    } catch (e) {
      throw Exception('Failed to get sensor history: $e');
    }
  }
}