import 'package:flutter/material.dart';

// Dummy HomeView page for back navigation
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.green[800], // Darker color for the app bar
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Backward arrow icon
          onPressed: () {
            Navigator.pop(context); // Navigates back to HomeView
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[300]!, Colors.green[200]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // Different color for the header
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(
                              'assets/files/samir_umak.jpg'), // Replace with user photo
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Kunal Salankar', // Replace with user name
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.green[800], // Contrasting text color
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Profile Options
                  _buildProfileOption(
                    icon: Icons.info,
                    title: 'Detailed Information',
                    onTap: () {
                      // Navigate to detailed information page
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.history,
                    title: 'Order History',
                    onTap: () {
                      // Navigate to order history page
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      // Navigate to settings page
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Log Out',
                    onTap: () {
                      // Handle logout
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () {
                      // Navigate to support page
                    },
                  ),

                  SizedBox(height: 30),

                  // Additional decorative element
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.green[300]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Center(
                        child: Text(
                          'Powered by Agroconnect',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.green[100]!, Colors.green[100]!],
              ),
            ),
            child: Icon(icon, color: Colors.green[600]), // Updated icon color
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[600]),
          onTap: onTap,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeView(), // Set HomeView as the initial screen
    routes: {
      '/profile': (context) => ProfilePage(), // Route for ProfilePage
    },
  ));
}
