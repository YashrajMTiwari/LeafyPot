import 'package:flutter/material.dart';
import 'package:leafypot/getting_started_and_login/greeting_page.dart';
import 'package:leafypot/getting_started_and_login/login_page.dart';
import 'package:leafypot/getting_started_and_login/signup_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'getting_started_and_login/dashboard_page.dart';

void main() async {

  await Supabase.initialize(
    url: 'https://jmsrllpcjgtolcdqhrlz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imptc3JsbHBjamd0b2xjZHFocmx6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY2NDU3NDQsImV4cCI6MjA0MjIyMTc0NH0.NVY4VM6Zo6csWlNhBBLwHgsziUr2Lw_h67LQAKhGNCw',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

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
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
    throw UnimplementedError();
  }

}