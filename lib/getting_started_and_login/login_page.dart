import 'dart:math';
import 'package:flutter/material.dart';
import 'package:leafypot/getting_started_and_login/dashboard_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data){
      final event  = data.event;
      if (event  == AuthChangeEvent.signedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          )
        );
      }
    });
  }

  Future<AuthResponse> _googleSignIn() async {

    const webClientId = '563831812544-19m66cd0lqfe0jq2g9lsbn1ns6qbk0rt.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Center(
              child: Image.asset(
                'asset/logo.png',
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 600,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _googleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(63, 107, 81, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Google login'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
