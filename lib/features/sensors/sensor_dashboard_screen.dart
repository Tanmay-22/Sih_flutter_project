import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';
import '../../core/services/sensor_service.dart';
import '../../core/models/sensor_data.dart';

class SensorDashboardScreen extends StatefulWidget {
  const SensorDashboardScreen({super.key});

  @override
  State<SensorDashboardScreen> createState() => _SensorDashboardScreenState();
}

class _SensorDashboardScreenState extends State<SensorDashboardScreen> {
  bool _isWaterPumpOn = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<String>(
                stream: SensorService.getRelayStatusStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _isWaterPumpOn = snapshot.data == 'ON';
                  }
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isWaterPumpOn 
                                ? AppTheme.primaryBlue.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.water,
                              size: 32,
                              color: _isWaterPumpOn ? AppTheme.primaryBlue : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pump Control',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _isWaterPumpOn 
                                          ? AppTheme.successGreen 
                                          : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isWaterPumpOn ? 'ON' : 'OFF',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: _isWaterPumpOn 
                                          ? AppTheme.successGreen 
                                          : AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Switch(
                                value: _isWaterPumpOn,
                                onChanged: _toggleWaterPump,
                                activeColor: AppTheme.primaryGreen,
                              ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<SensorData?>(
                stream: SensorService.getSensorDataStream(),
                builder: (context, snapshot) {
                  final data = snapshot.data ?? SensorData(
                    moisture: 0,
                    dht22Temperature: 0,
                    dht22Humidity: 0,
                    ldr: 0,
                    mq135: 0,
                    pH: 0,
                    mlx90614: 0,
                  );
                  
                  final stressValue = _calculatePlantStress(data);
                  
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStressColor(stressValue).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.eco,
                              size: 32,
                              color: _getStressColor(stressValue),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Plant Stress',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getStressLevel(stressValue),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            stressValue.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: _getStressColor(stressValue),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Live Sensor Data',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              StreamBuilder<SensorData?>(
                stream: SensorService.getSensorDataStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('Sensor stream error: ${snapshot.error}');
                  }
                  if (snapshot.hasData) {
                    print('Sensor data received: ${snapshot.data}');
                  }
                  
                  final data = snapshot.data ?? SensorData(
                    moisture: 0,
                    dht22Temperature: 0,
                    dht22Humidity: 0,
                    ldr: 0,
                    mq135: 0,
                    pH: 0,
                    mlx90614: 0,
                  );
                  
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildSensorCard(
                        'Moisture',
                        data.moisture.toStringAsFixed(1),
                        Icons.water_drop,
                        AppTheme.primaryBlue,
                      ),
                      _buildSensorCard(
                        'Temperature',
                        '${data.dht22Temperature.toStringAsFixed(1)}°C',
                        Icons.thermostat,
                        AppTheme.warningOrange,
                      ),
                      _buildSensorCard(
                        'Humidity',
                        '${data.dht22Humidity.toStringAsFixed(1)}%',
                        Icons.opacity,
                        AppTheme.secondaryBlue,
                      ),
                      _buildSensorCard(
                        'Light',
                        data.ldr > 0 ? 'Adequate' : 'Scarce',
                        Icons.wb_sunny,
                        Colors.amber[700]!,
                      ),
                      _buildSensorCard(
                        'Air Quality',
                        data.mq135.toStringAsFixed(0),
                        Icons.air,
                        AppTheme.successGreen,
                      ),
                      _buildSensorCard(
                        'pH Level',
                        data.pH.toStringAsFixed(1),
                        Icons.science,
                        Colors.purple[700]!,
                      ),
                      _buildSensorCard(
                        'Plant Temp',
                        '${data.mlx90614.toStringAsFixed(1)}°C',
                        Icons.device_thermostat,
                        Colors.red[700]!,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSensorCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoDataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.sensors_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Sensor Data Available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your sensor connections',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getMoistureStatus(double moisture) {
    if (moisture < 30) return 'Dry';
    if (moisture < 60) return 'Moderate';
    return 'Wet';
  }
  
  String _getTemperatureStatus(double temp) {
    if (temp < 15) return 'Cold';
    if (temp < 25) return 'Optimal';
    if (temp < 35) return 'Warm';
    return 'Hot';
  }
  
  String _getHumidityStatus(double humidity) {
    if (humidity < 40) return 'Low';
    if (humidity < 70) return 'Optimal';
    return 'High';
  }
  
  String _getLightStatus(double light) {
    if (light < 200) return 'Low Light';
    if (light < 800) return 'Moderate';
    return 'Bright';
  }
  
  String _getAirQualityStatus(double aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy';
    return 'Poor';
  }
  
  String _getPhStatus(double ph) {
    if (ph < 6.0) return 'Acidic';
    if (ph < 7.5) return 'Optimal';
    return 'Alkaline';
  }
  
  String _getMLXStatus(double temp) {
    if (temp < 20) return 'Cool';
    if (temp < 30) return 'Normal';
    return 'Warm';
  }
  
  double _calculatePlantStress(SensorData data) {
    double min(double a, double b) => a < b ? a : b;
    
    return 100 * (
      0.15 * min(1, (data.dht22Humidity - 50).abs() / 20) +
      0.15 * min(1, (data.dht22Temperature - 25).abs() / 5) +
      0.20 * min(1, (data.moisture - 30).abs() / 10) +
      0.15 * min(1, (data.ldr - 10000).abs() / 5000) +
      0.15 * min(1, (data.mq135 - 30).abs() / 70) +
      0.10 * min(1, (data.pH - 6.5).abs() / 1) +
      0.10 * min(1, (data.mlx90614 - 25).abs() / 3)
    );
  }
  
  Color _getStressColor(double stress) {
    if (stress < 20) return AppTheme.successGreen;
    if (stress < 40) return Colors.lightGreen;
    if (stress < 60) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }
  
  String _getStressLevel(double stress) {
    if (stress < 20) return 'Optimal';
    if (stress < 40) return 'Low Stress';
    if (stress < 60) return 'Moderate Stress';
    return 'High Stress';
  }
  
  void _toggleWaterPump(bool isOn) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await SensorService.toggleRelay(isOn);
      
      setState(() {
        _isWaterPumpOn = isOn;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Relay ${isOn ? 'turned ON' : 'turned OFF'}',
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}