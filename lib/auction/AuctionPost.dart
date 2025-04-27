import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AuctionPost extends StatefulWidget {
  @override
  _AuctionPostState createState() => _AuctionPostState();
}

class _AuctionPostState extends State<AuctionPost> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();
  final TextEditingController bidIncrementController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController farmerNameController = TextEditingController();
  final TextEditingController farmerMobileController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      String fileName = 'auction_images/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _createAuction() async {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl = await _uploadImage();
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image. Please try again.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('auctions').add({
          'productName': productNameController.text.trim(),
          'basePrice': basePriceController.text.trim(),
          'bidIncrement': bidIncrementController.text.trim(),
          'location': locationController.text.trim(),
          'farmerName': farmerNameController.text.trim(),
          'farmerMobile': farmerMobileController.text.trim(),
          'quantity': quantityController.text.trim(),
          'startDate': Timestamp.fromDate(_startDate!),
          'endDate': Timestamp.fromDate(_endDate!),
          'imageUrl': imageUrl,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auction created successfully!')),
        );

        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _startDate = null;
          _endDate = null;
        });

        Navigator.pop(context);
      } catch (e) {
        print('Error creating auction in Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create auction. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select dates and complete all fields.')),
      );
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        setState(() {
          final dateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          if (isStartDate) {
            _startDate = dateTime;
          } else {
            _endDate = dateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Auction'),
        backgroundColor: Colors.green[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter product name' : null,
              ),
              TextFormField(
                controller: basePriceController,
                decoration: InputDecoration(labelText: 'Base Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter base price' : null,
              ),
              TextFormField(
                controller: bidIncrementController,
                decoration: InputDecoration(labelText: 'Bid Increment'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter bid increment' : null,
              ),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? 'Please enter quantity' : null,
              ),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter location' : null,
              ),
              TextFormField(
                controller: farmerNameController,
                decoration: InputDecoration(labelText: 'Farmer Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter farmer name' : null,
              ),
              TextFormField(
                controller: farmerMobileController,
                decoration: InputDecoration(labelText: 'Farmer Mobile'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.isEmpty ? 'Please enter farmer mobile number' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _pickDate(context, true),
                child: Text(_startDate == null
                    ? 'Select Start Date & Time'
                    : 'Start Date: ${DateFormat('dd MMM yyyy, HH:mm').format(_startDate!)}'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _pickDate(context, false),
                child: Text(_endDate == null
                    ? 'Select End Date & Time'
                    : 'End Date: ${DateFormat('dd MMM yyyy, HH:mm').format(_endDate!)}'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Image'),
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.file(
                    _image!,
                    height: 200,
                  ),
                ),
              SizedBox(height: 16),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _createAuction,
                child: Text('Create Auction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}