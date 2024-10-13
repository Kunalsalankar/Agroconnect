import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googlemerr/driver.dart';
import 'package:googlemerr/splash_page.dart';
import 'package:googlemerr/transportation_services.dart';
import 'SignupPage.dart';
import 'home_view.dart';
import 'subscription.dart';

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
      initialRoute: '/',
      debugShowCheckedModeBanner: false,  // Disable the debug banner
      routes: {
        '/': (context) => HomeView(),  // Check if user is logged in
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomeView(),
        '/transportation_services': (context) => TransportationServicesPage(), // Transportation services page
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
            return HomeView();  // If logged in, go to home page
          }
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()), // Show loading indicator while waiting
        );
      },
    );
  }
}
