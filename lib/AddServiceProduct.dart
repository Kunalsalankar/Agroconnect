
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
class AddServiceProduct extends StatefulWidget {
  @override
  _AddServiceProductState createState() => _AddServiceProductState();
}

class _AddServiceProductState extends State<AddServiceProduct> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceWeeklyController = TextEditingController();
  final TextEditingController _priceMonthlyController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _aadharNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(); // New controller for location
  File? _image; // To hold the selected image

  final ImagePicker _picker = ImagePicker(); // Create an instance of ImagePicker

  bool _isLoading = false; // To indicate loading state

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Store the picked image file
      });
    }
  }

  // Function to add product to Firestore
  Future<void> _addProduct() async {
    String name = _nameController.text.trim();
    String priceWeekly = _priceWeeklyController.text.trim();
    String priceMonthly = _priceMonthlyController.text.trim();
    String mobileNo = _mobileNoController.text.trim();
    String farmerName = _farmerNameController.text.trim();
    String aadharNumber = _aadharNumberController.text.trim();
    String location = _locationController.text.trim(); // Get the location input

    // Input validation
    if (name.isEmpty ||
        priceWeekly.isEmpty ||
        priceMonthly.isEmpty ||
        mobileNo.isEmpty ||
        farmerName.isEmpty ||
        aadharNumber.isEmpty ||
        location.isEmpty) { // Check if location is filled
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String imageUrl = '';

    if (_image != null) {
      // Upload the image to Firebase Storage
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef =
        FirebaseStorage.instance.ref().child('product_images').child(fileName);
        UploadTask uploadTask = storageRef.putFile(_image!);

        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } else {
      // If no image selected, use a default placeholder image URL or asset path
      imageUrl = 'https://via.placeholder.com/150'; // You can use your own placeholder URL
    }

    // Create a product map
    Map<String, dynamic> product = {
      'name': name,
      'priceWeekly': 'Rs $priceWeekly Weekly', // Format price
      'priceMonthly': 'Rs $priceMonthly Monthly', //
      'mobile_no': mobileNo,
      'farmer_name': farmerName,
      'aadhar_number': aadharNumber,
      'location': location, // Add the location to the product map
      'image': imageUrl, // Use the uploaded image URL or placeholder
      'timestamp': FieldValue.serverTimestamp(), // Optional: to order by latest
    };

    // Add product to Firestore
    try {
      await FirebaseFirestore.instance.collection('products').add(product);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully')),
      );

      // Go back to the previous page after adding the product
      Navigator.pop(context);
    } catch (e) {
      print('Error adding product to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceWeeklyController.dispose();
    _priceMonthlyController.dispose();
    _mobileNoController.dispose();
    _farmerNameController.dispose();
    _aadharNumberController.dispose();
    _locationController.dispose(); // Dispose the location controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Service Product"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        // Scrollable container to handle overflow
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: Column(
            children: [
              SizedBox(height: 20), // Optional padding to improve layout
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _priceWeeklyController,
                decoration: InputDecoration(
                  labelText: 'Price Weekly',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // Use number keyboard for prices
              ),
              SizedBox(height: 10),
              TextField(
                controller: _priceMonthlyController,
                decoration: InputDecoration(
                  labelText: 'Price Monthly',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _mobileNoController,
                decoration: InputDecoration(
                  labelText: 'Mobile No',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone, // Phone keyboard for mobile number
              ),
              SizedBox(height: 10),
              TextField(
                controller: _farmerNameController,
                decoration: InputDecoration(
                  labelText: 'Farmer Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _aadharNumberController,
                decoration: InputDecoration(
                  labelText: 'Aadhar Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _locationController, // New TextField for location
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              // Image selection button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text("Select Image"),
                style: ElevatedButton.styleFrom(),
              ),
              SizedBox(height: 20),
              // Display the selected image
              _image != null
                  ? Image.file(
                _image!,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              )
                  : Text("No image selected"),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addProduct,
                child: Text("Add Product"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
