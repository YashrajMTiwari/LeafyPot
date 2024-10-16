import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  final String? displayName;
  const DashboardPage({Key? key, this.displayName }): super(key: key);
  
  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'asset/logo.png',
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
          const Positioned(
            top: 50,
            left: 0,
            child: Icon(
              Icons.circle_notifications
            ),
          ),
        ],
      ),
    );
    throw UnimplementedError();
  }
}
