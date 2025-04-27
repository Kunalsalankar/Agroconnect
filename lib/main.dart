import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googlemerr/Transportation/driver.dart';
import 'package:googlemerr/SignUp/splash_page.dart';
import 'home_page/home_view.dart';
import 'subscription.dart';
import 'Transportation/transportation_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false, // Disable the debug banner
      home: AuthWrapper(), // Set the initial route to AuthWrapper
      routes: {
        '/signup': (context) => SplashPage(),
        '/home': (context) => HomeView(),
        '/driver': (context) => DriverRegistrationPage(),
        '/subscription': (context) => SubscriptionPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return SplashPage(); // If not logged in, show sign up page
          } else {
            return HomeView(); // If logged in, go to home page
          }
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()), // Show loading indicator while waiting
        );
      },
    );
  }
}