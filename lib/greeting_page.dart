import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'AuthService.dart';

class GreetingPage extends StatefulWidget {
  const GreetingPage({super.key});

  @override
  GreetingPageState createState() => GreetingPageState();
}

class GreetingPageState extends State<GreetingPage> {

  final AuthService _authService = AuthService();

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

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
/*
    var _isLoading = false;

    void _onSubmit() {
      setState(() => _isLoading = true);
      Future.delayed(
        const Duration(seconds: 2),
          () => setState(() => _isLoading = false),
      );
    }
*/
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
              top: screenHeight * 0.07,
              left: 0,
              right: 0,
              child: Image.asset(
                'asset/logo.png',
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.16,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Text("Login Options"),
                                  ElevatedButton(
                                    onPressed: () async {
                                      User? user = await _authService.signInWithGoogle();
                                      if (user != null) {
                                        Navigator.pushReplacementNamed(context, '/dashboard');
                                        if (kDebugMode) {
                                          print('Signed in: ${user.displayName}');
                                        }
                                      } else {
                                        if (kDebugMode) {
                                          print('Failed to sign in with Google');
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(63, 107, 81, 1),
                                        foregroundColor: Colors.white,
                                        textStyle: const TextStyle(fontSize: 20),
                                    ),
                                    child: const Text("Google Login"),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                      );
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