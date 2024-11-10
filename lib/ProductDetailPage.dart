
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'buyMilk.dart';
import 'ChatRoomPage.dart'; // Import the chat room page
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                product['productName'] ?? 'Product Detail',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Hero(
                tag: 'product-image-${product['id']}',
                child: _buildImage(product),
              ),
            ),
            backgroundColor: Colors.green[800],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.green, width: 2),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.price_change, 'Price',
                              product['price']?.toString() ?? 'N/A'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.scale, 'Quantity',
                              product['quantity']?.toString() ?? 'N/A'),
                          SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.location_pin,
                            'Location',
                            product['location'] ?? 'N/A',
                          ),
                          SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.person,
                            'Farmer Name',
                            product['farmerName'] ?? 'N/A',
                          ),
                          SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.credit_card,
                            'Aadhar Number',
                            product['aadharNumber'] ?? 'N/A',
                          ),
                          SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.date_range,
                            'Harvest Date',
                            product['harvestDate'] ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.monetization_on, size: 28),
                    label: Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyMilkPage(product: product),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadowColor: Colors.blueAccent.withOpacity(0.5),
                      elevation: 8,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.phone_in_talk, size: 24),
                          label: Text(
                            'Call Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          onPressed: () {
                            final mobileNumber = product['mobile_no'] ?? '';
                            if (mobileNumber.isNotEmpty) {
                              final Uri url = Uri(
                                scheme: 'tel',
                                path: mobileNumber,
                              );
                              launchUrl(url);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            shadowColor: Colors.teal.withOpacity(0.5),
                            elevation: 8,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.chat_bubble_outline, size: 24),
                          label: Text(
                            'Chat Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          onPressed: () async {
                            String? username = await _getUsername();
                            String farmerName = product['farmerName'] ?? 'Farmer';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoomPage(
                                  username: username ?? 'Guest', // Provide a default if null
                                  farmerName: farmerName,
                                  chatId: product['id'] ?? '', // Ensure this is not null
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            shadowColor: Colors.purple.withOpacity(0.5),
                            elevation: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    // Fetch the username from Firestore or authentication
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userDoc['username']; // Adjust based on your Firestore structure
    }
    return null; // Handle the case where the user is not found
  }


  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildImage(Map<String, dynamic> item) {
    String imagePath = item['imageUrl'] ?? '';
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
    }
  }
}