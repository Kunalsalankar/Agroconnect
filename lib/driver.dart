import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

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
  final TextEditingController capacityController = TextEditingController(); // New controller for capacity
  String? imagePath;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _registerDriver() async {
    if (_formKey.currentState!.validate() && imagePath != null) {
      // Store driver details in Firebase Firestore
      await FirebaseFirestore.instance.collection('driver').add({
        'name': nameController.text,
        'vehicle': vehicleController.text,
        'license': licenseController.text,
        'mobile': mobileController.text,
        'address': addressController.text,
        'rate': rateController.text,
        'capacity': capacityController.text, // Store capacity
        'imagePath': imagePath,
      });

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Driver Registered Successfully!')));
      Navigator.pop(context); // Navigate back to TransportationServicesPage
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image and fill all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Registration'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Upload Image'),
                    ),
                    SizedBox(width: 10),
                    if (imagePath != null)
                      Text('Image selected: ${imagePath!.split('/').last}'),
                  ],
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
