import 'dart:math';
import 'package:flutter/material.dart';
import 'package:leafypot/getting_started_and_login/login_page.dart';

class GreetingPage extends StatefulWidget {
  const GreetingPage({super.key});

  @override
  GreetingPageState createState() => GreetingPageState();
}

class GreetingPageState extends State<GreetingPage> {

  final List<String> funFacts = [
    "Plants can communicate with each other through their roots.",
    "Some plants can survive for months without water.",
    "Bananas are technically herbs, not trees.",
    "Bamboo is the fastest-growing plant in the world.",
    "Plants can clean air and improve indoor air quality.",
    "The smell of freshly-cut grass is a plant distress call.",
    "The Amazon rainforest produces 20% of the world's oxygen.",
    "Some plants can move, like the Venus Flytrap.",
  ];

  String selectedFact = "";

  @override
  void initState() {
    super.initState();
    generateRandomFact();
  }

  void generateRandomFact() {
    final random = Random();
    setState(() {
      selectedFact = funFacts[random.nextInt(funFacts.length)];
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeafyPot_GreetingPage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Image.asset(
                'asset/img.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Image.asset(
                'asset/logo.png',
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(63, 107, 81, 1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 20),
                    textStyle: const TextStyle(fontSize: 20)
                  ),
                  child: const Text('Get Started '),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 26,
              right: 26,
              child: Text(
                selectedFact,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}