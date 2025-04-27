import 'package:flutter/material.dart';
import '../SignUp/SignupPage.dart';
class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add a gradient background for a modern look
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green[400]!, // Start with a darker green
              Colors.green[400]!, // Lighter green towards the bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or image with subtle animation for smooth appearance
              AnimatedContainer(
                duration: Duration(seconds: 2),
                curve: Curves.easeInOut,
                child: Image.asset(
                  'assets/files/icon.png', // Replace with your actual logo or image path
                  width: 180,
                  height: 180,
                ),
              ),
              SizedBox(height: 30),

              // App name with a more dynamic font and shadow for depth
              Text(
                'Agriconnect',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Keep the text white for contrast
                  letterSpacing: 2, // Add some spacing between letters
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 3,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),

              // Tagline with a more subtle font style
              Text(
                'Empowering farmers, connecting markets',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70, // Softer color for tagline
                  fontStyle: FontStyle.italic, // Italicized for style
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),

              // Start button with a modern raised style
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  shadowColor: Colors.black38, // Subtle shadow for depth
                  elevation: 5, // Slight elevation for the button
                  padding: EdgeInsets.symmetric(
                      horizontal: 50, vertical: 18), // Spacious button
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5, // Spacing for a sleek look
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
