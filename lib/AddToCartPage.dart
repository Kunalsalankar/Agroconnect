import 'package:flutter/material.dart';
import 'home_view.dart'; // Import your HomeView page
import 'package:cloud_firestore/cloud_firestore.dart';

class AddToCartPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const AddToCartPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to Cart'),
        backgroundColor: Colors.green[800], // Dark green color for AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeView()), // Navigate to HomeView
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Reduced overall padding
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85, // Set width to 85% of screen
              decoration: BoxDecoration(
                color: Colors.white, // White background for the container
                borderRadius: BorderRadius.circular(12), // Slightly smaller border radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image with reduced size
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      product['photo'] ?? 'assets/images/default_image.png', // Default image if not found
                      width: double.infinity,
                      height: 120, // Further reduced height
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0), // Reduced padding inside the container
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          product['name'] ?? 'Unknown Product', // Default text if name is null
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        SizedBox(height: 4), // Reduced spacing

                        // Price
                        Text(
                          'Price: ₹${product['price'] ?? 0} / Quintal', // Default price if null
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                        SizedBox(height: 4), // Reduced spacing

                        // Location
                        Text(
                          'Location: ${product['location'] ?? 'Unknown'}', // Default location if null
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4), // Reduced spacing

                        // Quantity
                        Text(
                          'Quantity: ${product['quantity'] ?? 0} Quintal', // Default quantity if null
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Buy Now Button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _addToCart(context, product); // Add to cart functionality
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Reduced button padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Slightly reduced radius
                              ),
                            ),
                            child: Text(
                              'Buy Now',
                              style: TextStyle(
                                fontSize: 18, // Slightly reduced font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Changed to white for better contrast
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8), // Reduced space below button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context, Map<String, dynamic> product) async {
    // Get a reference to Firestore
    final CollectionReference cartCollection = FirebaseFirestore.instance.collection('cart');

    try {
      // Add product to Firestore
      await cartCollection.add({
        'name': product['name'] ?? 'Unknown Product',
        'price': product['price'] ?? 0,
        'location': product['location'] ?? 'Unknown',
        'quantity': product['quantity'] ?? 0,
        'photo': product['photo'] ?? 'assets/images/default_image.png',
        'timestamp': FieldValue.serverTimestamp(), // Optional: add timestamp
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added to cart!')),
      );

      // Optionally navigate back to HomeView or another page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeView()),
      );
    } catch (e) {
      // Handle errors and log them
      print('Error adding to cart: $e'); // Debug information
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
  }
}
