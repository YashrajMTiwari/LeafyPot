import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leafypot/profile_page.dart';
import 'addPlant_page.dart';
import 'firestore_service.dart';
import 'plant_detail_page.dart';

class DashboardPage extends StatefulWidget {
  final String? displayName;

  const DashboardPage({super.key, this.displayName});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _plants = [];
  String? _userId;

  final List<String> _attentionMessages = [
    "Your plants are waiting for you!",
    "Time to check on your leafy friends!",
    "Don't forget to water your plants today.",
    "Your plants are ready for some TLC!",
    "They miss you, go take care of them!",
    "Give your plants the love they deserve!",
    "Plants are waiting for their daily care.",
    "Is your garden thirsty today?",
    "Have you checked your plants today?",
    "Your plants are growing stronger with your care!",
    "Go ahead, give your plants a hug!",
  ];

  String _getRandomMessage() {
    final random = Random();
    return _attentionMessages[random.nextInt(_attentionMessages.length)];
  }

  @override
  void initState() {
    super.initState();
    _fetchUserPlants();
  }

  Future<void> _fetchUserPlants() async {
    _userId = getCurrentUserId();
    print('Current User ID: $_userId');

    if (_userId != null) {
      List<Map<String, dynamic>> plants = await fetchPlants(_userId!);
      print('Fetched plants: $plants');
      setState(() {
        _plants = plants;
      });
    } else {
      print('No user is signed in');
    }
  }


  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    print('Current user: ${user?.uid}');
    return user?.uid;
  }

  Future<List<Map<String, dynamic>>> fetchPlants(String userId) async {
    List<Map<String, dynamic>> plantsList = [];

    try {
      print('Fetching plants for user ID: $userId');
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('plants')
          .where('user_id', isEqualTo: userId)
          .get();

      print('Snapshot docs: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('No plants found for user $userId');
      } else {
        for (var doc in snapshot.docs) {
          var moistureData = doc['plant_mos'];

          int moisture = 0;
          if (moistureData is String) {
            moisture = int.tryParse(moistureData) ?? 0;
          } else if (moistureData is int) {
            moisture = moistureData;
          }

          plantsList.add({
            ...doc.data() as Map<String, dynamic>,
            'plant_id': doc.id,
            'plant_moisture': moisture,
          });
        }
      }
    } catch (e) {
      print('Error fetching plants: $e');
    }

    return plantsList;
  }



  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.06,
            left: screenWidth * 0.05,
            child: Image.asset(
              'asset/logo.png',
              height: 70,
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
          // Notification Button
          /*
          Positioned(
            top: 60,
            right: 20,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(63, 107, 81, 1),
                shape: const CircleBorder(),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
           */
          // Welcome User
          // Welcome User
          Positioned(
            top: screenHeight * 0.17,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Container(
              height: 120.0,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(63, 107, 81, 1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      'Welcome, ${FirebaseAuth.instance.currentUser?.displayName ?? 'Guest'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(seconds: 1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.white70,
                      ),
                      child: Text(
                        _getRandomMessage(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.34,
            left: screenWidth * 0.05,
            child: const Text(
              "MY PLANTS",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.38,
            left: screenWidth * 0.05,
            child: Text(
              "You have ${_plants.length} plants",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.42,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _plants.isEmpty
                  ? const Text(
                'No plants available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
                  : Row(
                children: _plants.map((plant) {
                  print('Plant: ${plant['plant_name']}');
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlantDetailPage(
                            plantId: plant['plant_id'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      height: 200,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(63, 107, 81, 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.nature_outlined,
                              color: Colors.white,
                              size: 110,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              plant['plant_name'] ?? 'Unnamed Plant',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              plant['plant_type'] ?? 'Unknown Type',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.0,
            left: 0,
            right: 0,
            child: Container(
              height: 90.0,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_rounded,
                          color: Colors.black,
                          size: 50,
                        ),
                        Text(
                          'Home',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -screenHeight * 0.055),
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddPlantPage()),
                        );

                        if (result == true) {
                          _fetchUserPlants();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        minimumSize: const Size(70, 70),
                        backgroundColor: const Color.fromRGBO(63, 107, 81, 1),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          color: Colors.black,
                          size: 50,
                        ),
                        Text(
                          'Profile',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
