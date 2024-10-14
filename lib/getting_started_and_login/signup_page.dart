import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "LeafyPot_LoginPage",
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
                child: Center(
                  child: Image.asset(
                    'asset/logo.png',
                    height: 70,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 300,
                left: 0,
                right: 0,
                child: Center(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email ID',
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 400,
                left: 0,
                right: 0,
                child: Center(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 500,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(63, 107, 81, 1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20)
                    ),
                    child: const Text('Sign Up'),
                  ),
                ),
              ),
              Positioned(
                top: 600,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(63, 107, 81, 1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                        textStyle: const TextStyle(fontSize: 20),
                      minimumSize: const Size(50, 50),
                    ),
                    child: const Text('Back To Login'),
                  ),
                ),
              ),
            ]
        ),
      ),
    );
    throw UnimplementedError();
  }

}