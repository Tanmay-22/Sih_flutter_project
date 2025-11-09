class FirebaseConfig {
  // Replace these with your actual Firebase project details
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String databaseUrl = 'https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com/';
  
  // Sensor data collection paths
  static const String sensorsPath = 'sensors';
  static const String currentSensorPath = 'sensors/current';
  static const String sensorHistoryPath = 'sensors/history';
  static const String controlsPath = 'controls';
  
  // Real-time database paths for sensor data
  static const String realtimeSensorsPath = '/sensors';
  static const String realtimeControlsPath = '/controls';
}