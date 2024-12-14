import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'CameraPage.dart';

class PlantDetailPage extends StatefulWidget {
  final String plantId;

  const PlantDetailPage({super.key, required this.plantId});

  @override
  _PlantDetailPageState createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic> _plant = {};

  @override
  void initState() {
    super.initState();
    _fetchPlantDetails();
  }

  Future<void> _fetchPlantDetails() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('plants')
        .doc(widget.plantId)
        .get();

    if (snapshot.exists) {
      setState(() {
        _plant = snapshot.data() as Map<String, dynamic>;
      });
    }
  }
  int _daysSinceLastCheck(Timestamp? lastHealthCheck) {
    if (lastHealthCheck != null) {
      DateTime lastCheckDate = lastHealthCheck.toDate();
      DateTime currentDate = DateTime.now();
      Duration difference = currentDate.difference(lastCheckDate);
      return difference.inDays;
    } else {
      return 0;
    }
  }

  Widget _buildHealthStatus(String healthStatus, int daysSinceLastCheck) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(63, 107, 81, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            healthStatus == 'healthy' ? 'healthy' : 'unhealthy',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Icon(
            healthStatus == 'healthy'
                ? Icons.sentiment_very_satisfied
                : Icons.sentiment_very_dissatisfied,
            color: Colors.white,
            size: 50,
          ),
          const SizedBox(height: 10),
          Text(
            daysSinceLastCheck == 0
                ? 'Health check today'
                : '$daysSinceLastCheck days since last health check',
            style: const TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  Widget _buildMoistureProgressBar(int moistureLevel) {
    double moisturePercentage = (moistureLevel / 250) * 100;

    Color progressColor;
    if (moisturePercentage >= 75) {
      progressColor = Colors.green;
    } else if (moisturePercentage >= 50) {
      progressColor = Colors.yellow;
    } else if (moisturePercentage >= 25) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromRGBO(63, 107, 81, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Moisture Level',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[300]!),
                ),
              ),

              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: moistureLevel / 250,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),

              Text(
                '${moisturePercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }


  Future<void> _deletePlant() async {
    try {
      await FirebaseFirestore.instance.collection('plants').doc(widget.plantId).delete();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting plant: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(_plant['plant_name'] ?? 'Plant Details', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [

          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () {

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Plant'),
                    content: const Text('Are you sure you want to delete this plant?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _deletePlant();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: _plant.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              '${_plant['plant_type']}',
              style: const TextStyle(fontSize: 24, color: Color.fromRGBO(63, 107, 81, 1)),
            ),
            const SizedBox(height: 20),
            Container(
              width: screenWidth,
              height: screenHeight * 0.25,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(63, 107, 81, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildHealthStatus(
                  _plant['plant_health'] ?? 'Unknown',
                  _daysSinceLastCheck(_plant['last_health_check'])),
            ),
            const SizedBox(height: 20),

            Container(
              width: screenWidth,
              height: screenHeight * 0.41,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(63, 107, 81, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildMoistureProgressBar(int.tryParse(_plant['plant_mos']?.toString() ?? '0') ?? 0),
            ),

            const SizedBox(height: 20),

            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                bool? shouldRefresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraPage(plantId: widget.plantId),
                  ),
                );

                if (shouldRefresh == true) {
                  _fetchPlantDetails();
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromRGBO(63, 107, 81, 1),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Check Health',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
