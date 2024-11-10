import 'package:flutter/material.dart';

class ProfileSetting extends StatefulWidget {
  @override
  _ProfileSettingState createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  String category = 'Farmer'; // Default category

  @override
  void initState() {
    super.initState();
    // Set default values or fetch from the database
    nameController.text = 'Kuldip Chauhan';
    emailController.text = 'kuldipchauhan2021@gmail.com';
    contactController.text = '9322728749';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
        backgroundColor: Colors.green[800],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Implement profile picture upload
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green[800],
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Implement profile picture delete
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green[800],
                        child: Icon(Icons.delete, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            buildTextField('Full Name', nameController, Icons.person, false),
            buildTextField('Email Address', emailController, Icons.email, false,
                ),
            buildDropdown('Category', ['Farmer', 'Buyer', 'Trader']),
            buildTextField('Contact Number', contactController, Icons.phone, false, isPhoneNumber: true),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Save changes functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Save Changes', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, IconData icon, bool obscureText,
      {Widget? suffix, bool isPhoneNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isPhoneNumber ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon),
          suffix: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: category,
            onChanged: (newValue) {
              setState(() {
                category = newValue!;
              });
            },
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
