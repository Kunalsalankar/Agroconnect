import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io'; // Import dart:io for File

class DriverRegistrationPage extends StatefulWidget {
  @override
  _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController capacityController = TextEditingController(); // Controller for capacity
  String? imagePath; // Path for storing selected image

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  // Function to upload the image to Firebase Storage
  Future<String?> _uploadImage() async {
    if (imagePath == null) return null;

    // Create a reference to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('driver_images/${DateTime.now().millisecondsSinceEpoch}.png');

    // Upload the file to Firebase Storage
    final uploadTask = storageRef.putFile(File(imagePath!));
    await uploadTask;

    // Get the download URL
    return await storageRef.getDownloadURL();
  }

  // Function to register the driver
  Future<void> _registerDriver() async {
    if (_formKey.currentState!.validate()) {
      // Upload image and get the URL
      String? imageUrl = await _uploadImage();
      if (imageUrl != null) {
        // Store driver details in Firebase Firestore
        await FirebaseFirestore.instance.collection('driver').add({
          'name': nameController.text,
          'vehicle': vehicleController.text,
          'license': licenseController.text,
          'mobile': mobileController.text,
          'address': addressController.text,
          'rate': rateController.text,
          'capacity': capacityController.text, // Store capacity
          'imagePath': imageUrl, // Store the download URL
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Driver Registered Successfully!'),
            backgroundColor: Colors.green, // You can style the message
          ),
        );

        // Optionally, navigate back after showing the message
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context); // Navigate back after showing the message
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to upload image. Please try again.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all fields.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Registration'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver Name
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Driver Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the driver\'s name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Vehicle Type
                TextFormField(
                  controller: vehicleController,
                  decoration: InputDecoration(labelText: 'Vehicle Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the vehicle type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // License Number
                TextFormField(
                  controller: licenseController,
                  decoration: InputDecoration(labelText: 'License Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the license number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Mobile Number
                TextFormField(
                  controller: mobileController,
                  decoration: InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the mobile number';
                    } else if (value.length != 10) {
                      return 'Mobile number must be 10 digits';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Address
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Rate per km
                TextFormField(
                  controller: rateController,
                  decoration: InputDecoration(labelText: 'Rate per Km'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the rate per km';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Capacity
                TextFormField(
                  controller: capacityController,
                  decoration: InputDecoration(labelText: 'Vehicle Capacity '),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the vehicle capacity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Upload Image Button
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Upload Image'),
                ),

                SizedBox(height: 20),

                // Register Button
                Center(
                  child: ElevatedButton(
                    onPressed: _registerDriver,
                    child: Text('Register Driver'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
