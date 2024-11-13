import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'buy_now.dart';
import 'ChatRoomPage.dart';
import 'AddToCartPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    // Store product details locally when viewing this page
    _storeOrderInLocalStorage(product);

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
                          _buildDetailRow(Icons.price_change, 'Price', product['price']?.toString() ?? 'N/A'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.scale, 'Quantity', product['quantity']?.toString() ?? 'N/A'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.location_pin, 'Location', product['location'] ?? 'N/A'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.person, 'Farmer Name', product['farmerName'] ?? 'N/A'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.phone, 'Mobile Number', product['aadharNumber'] ?? 'N/A'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.date_range, 'Harvest Date', product['harvestDate'] ?? 'N/A'),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.monetization_on, size: 28),
                    label: Text(
                      'Buy Now',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[600]),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BuyNowPage(product: product)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      shadowColor: Colors.blueAccent.withOpacity(0.5),
                      elevation: 8,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.shopping_cart, size: 24),
                    label: Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[600]),
                    ),
                    onPressed: () async {
                      await _addToCart(product);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddToCartPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      shadowColor: Colors.orangeAccent.withOpacity(0.5),
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
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[600]),
                          ),
                          onPressed: () {
                            final mobileNumber = product['aadharNumber'] ?? '';
                            _makePhoneCall(context, mobileNumber);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            shadowColor: Colors.teal.withOpacity(0.5),
                            elevation: 8,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.chat_bubble_outline, size: 24),
                          label: Text(
                            'Chat Now',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[600]),
                          ),
                          onPressed: () {
                            final mobileNumber = product['aadharNumber'] ?? '';
                            _sendWhatsAppMessage(context, mobileNumber);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            shadowColor: Colors.purple.withOpacity(0.5),
                            elevation: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Store product details locally
  Future<void> _storeOrderInLocalStorage(Map<String, dynamic> product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('productId', product['id']);
    await prefs.setString('productName', product['productName']);
    await prefs.setString('price', product['price']?.toString() ?? '0');
    await prefs.setString('quantity', product['quantity']?.toString() ?? '0');

    // Save the order in both "users" and "order id" collections
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Save in "users" collection under the user's cart
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(product['id'])
          .set(product);

      // Save in "order id" collection with unique order ID
      final orderId = FirebaseFirestore.instance.collection('order_id').doc().id;
      await FirebaseFirestore.instance
          .collection('order_id')
          .doc(orderId)
          .set({
        'orderId': orderId,
        'userId': user.uid,
        'productId': product['id'],
        'productName': product['productName'],
        'price': product['price'],
        'quantity': product['quantity'],
        'location': product['location'],
        'farmerName': product['farmerName'],
        'aadharNumber': product['aadharNumber'],
        'harvestDate': product['harvestDate'],
        'mobileNumber': product['mobileNumber'],
        'orderDate': DateTime.now().toString(),
      });
    }
  }


  Future<void> _addToCart(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(product['id'])
          .set(product);
    }
  }

  void _sendWhatsAppMessage(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mobile number not available')),
      );
      return;
    }

    final Uri whatsappUrl = Uri.parse(
        "https://wa.me/$phoneNumber?text=Hello, I am interested in your product.");
    if (await canLaunch(whatsappUrl.toString())) {
      await launch(whatsappUrl.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  void _makePhoneCall(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mobile number not available')),
      );
      return;
    }

    final Uri phoneUri = Uri.parse("tel:$phoneNumber");
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone')),
      );
    }
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
