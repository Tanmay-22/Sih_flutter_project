import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class IoTDashboardScreen extends StatefulWidget {
  const IoTDashboardScreen({super.key});

  @override
  State<IoTDashboardScreen> createState() => _IoTDashboardScreenState();
}

class _IoTDashboardScreenState extends State<IoTDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _pumpStatus = false;
  bool _isUpdatingPump = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Dashboard'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('sensors').doc('current').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSensorGrid(data),
                  const SizedBox(height: 24),
                  _buildPumpControl(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSensorGrid(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildSensorCard(
          'Temperature',
          '${data['temperature']?.toStringAsFixed(1) ?? '--'}°C',
          Icons.thermostat,
          AppTheme.warningOrange,
        ),
        _buildSensorCard(
          'Humidity',
          '${data['humidity']?.toStringAsFixed(1) ?? '--'}%',
          Icons.water_drop,
          AppTheme.primaryBlue,
        ),
        _buildSensorCard(
          'Light',
          '${data['light']?.toStringAsFixed(0) ?? '--'} lux',
          Icons.wb_sunny,
          Colors.amber,
        ),
        _buildSensorCard(
          'Air Quality',
          '${data['airQuality']?.toStringAsFixed(0) ?? '--'} ppm',
          Icons.air,
          AppTheme.secondaryGreen,
        ),
      ],
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPumpControl() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('controls').doc('pump').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          _pumpStatus = data['status'] ?? false;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.water,
                      color: _pumpStatus ? AppTheme.primaryGreen : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Water Pump',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _pumpStatus ? 'Running' : 'Stopped',
                            style: TextStyle(
                              color: _pumpStatus ? AppTheme.primaryGreen : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _pumpStatus,
                      onChanged: _isUpdatingPump ? null : _togglePump,
                      activeColor: AppTheme.primaryGreen,
                    ),
                  ],
                ),
                if (_isUpdatingPump)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _togglePump(bool value) async {
    setState(() {
      _isUpdatingPump = true;
    });

    try {
      await _firestore.collection('controls').doc('pump').set({
        'status': value,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pump ${value ? 'started' : 'stopped'} successfully'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error controlling pump: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      setState(() {
        _isUpdatingPump = false;
      });
    }
  }
}