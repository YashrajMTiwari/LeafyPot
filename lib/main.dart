import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leafypot/getting_started_and_login/greeting_page.dart';
import 'package:leafypot/getting_started_and_login/login_page.dart';
import 'getting_started_and_login/dashboard_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes : {
        '/': (context) => const GreetingPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
    throw UnimplementedError();
  }

}