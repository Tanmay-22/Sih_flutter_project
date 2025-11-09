import 'package:flutter/material.dart';
import '../../../core/services/sensor_service.dart';
import '../../../core/models/sensor_data.dart';

class SensorDataWidget extends StatelessWidget {
  const SensorDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorData?>(
      stream: SensorService.getSensorDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final data = snapshot.data;
        if (data == null) {
          return const Center(child: Text('No sensor data available'));
        }
        
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sensor Data', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                _buildSensorRow('Moisture', '${data.moisture.toStringAsFixed(1)}%'),
                _buildSensorRow('Temperature (DHT22)', '${data.dht22Temperature.toStringAsFixed(1)}°C'),
                _buildSensorRow('Humidity (DHT22)', '${data.dht22Humidity.toStringAsFixed(1)}%'),
                _buildSensorRow('Light (LDR)', data.ldr.toStringAsFixed(0)),
                _buildSensorRow('Air Quality (MQ135)', data.mq135.toStringAsFixed(0)),
                _buildSensorRow('pH Level', data.pH.toStringAsFixed(1)),
                _buildSensorRow('MLX90614 Temp', '${data.mlx90614.toStringAsFixed(1)}°C'),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSensorRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  

}