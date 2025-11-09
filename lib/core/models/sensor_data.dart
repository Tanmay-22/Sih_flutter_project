class SensorData {
  final double dht22Temperature;
  final double dht22Humidity;
  final double ldr;
  final double mlx90614;
  final double mq135;
  final double moisture;
  final double pH;

  SensorData({
    required this.dht22Temperature,
    required this.dht22Humidity,
    required this.ldr,
    required this.mlx90614,
    required this.mq135,
    required this.moisture,
    required this.pH,
  });

  // Convert Firebase data to SensorData object
  factory SensorData.fromFirebase(Map<String, dynamic> data) {
    final sensors = data['Sensors'] ?? {};
    return SensorData(
      dht22Temperature: (sensors['DHT22']?['Temperature'] ?? 0).toDouble(),
      dht22Humidity: (sensors['DHT22']?['Humidity'] ?? 0).toDouble(),
      ldr: (sensors['LDR']?['Status'] == 'Bright' ? 1000 : 100).toDouble(),
      mlx90614: (sensors['MLX90614']?['ObjectTemp'] ?? 0).toDouble(),
      mq135: (sensors['MQ135']?['Raw'] ?? 0).toDouble(),
      moisture: (sensors['Moisture']?['Percent'] ?? 0).toDouble(),
      pH: (sensors['pH'] ?? 0).toDouble(),
    );
  }

  // Convert to Firebase format
  Map<String, dynamic> toFirebase() {
    return {
      'Sensors': {
        'DHT22': {
          'temperature': dht22Temperature,
          'humidity': dht22Humidity,
        },
        'LDR': ldr,
        'MLX90614': mlx90614,
        'MQ135': mq135,
        'Moisture': moisture,
        'pH': pH,
      },
    };
  }
}

class ActuatorData {
  final String relay;

  ActuatorData({required this.relay});

  factory ActuatorData.fromFirebase(Map<String, dynamic> data) {
    final actuators = data['Actuators'] ?? {};
    return ActuatorData(
      relay: actuators['Relay'] ?? 'OFF',
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      'Actuators': {
        'Relay': relay,
      },
    };
  }
}