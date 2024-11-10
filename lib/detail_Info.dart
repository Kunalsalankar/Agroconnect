// detail_info.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googlemerr/SignupPage.dart';
import 'ProfileSetting.dart';

class DetailInfo extends StatefulWidget {
  @override
  _DetailInfoState createState() => _DetailInfoState();
}

class _DetailInfoState extends State<DetailInfo> {
  String username = "Loading..."; // Default text while fetching username

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the username when the page initializes
  }

  Future<void> _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          username = userDoc['username'] ?? 'Unknown'; // Update the username
        });
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.green[800],
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage('assets/files/samir_umak.jpg'),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.green[800],
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            username, // Display the fetched username here
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.all(10),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.black87),
                    title: Text('Profile Settings'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileSetting()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.black87),
                    title: Text('Change Password'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      // Handle Change Password tap
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.post_add, color: Colors.black87),
                    title: Text('My Posts'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      // Handle My Posts tap
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.store, color: Colors.black87),
                    title: Text('Agri Shop'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      // Handle Agri Shop tap
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_bag, color: Colors.black87),
                    title: Text('My Store'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      // Handle My Store tap
                    },
                  ),

                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.black87),
                    title: Text('Logout'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                            (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
