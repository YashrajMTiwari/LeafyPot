import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AuthService.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {

  final AuthService _authService = AuthService();

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
                onPressed: () async {
                  User? user = await _authService.signInWithGoogle();
                  if (user != null) {
                    Navigator.pushReplacementNamed(context, '/dashboard', arguments: user.displayName);
                    print('Signed in: ${user.displayName}');
                  } else {
                    print('Failed to sign in with Google');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(63, 107, 81, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
