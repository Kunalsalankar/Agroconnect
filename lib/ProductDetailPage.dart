import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'AddToCartPage.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Validate necessary fields
    if (!product.containsKey('id') ||
        !product.containsKey('mobile_no') ||
        !product.containsKey('farmer_name') ||
        !product.containsKey('aadhar_number') ||
        !product.containsKey('harvest_date') ||
        !product.containsKey('video_url')) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Text(
            'Invalid product data',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(product['name'] ?? 'Product Detail'),
              background: Hero(
                tag: 'product-image-${product['id']}',
                child: Image.asset(
                  product['photo'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
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
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.price_change, 'Price',
                              '₹${product['price']} / Quintal'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.location_on, 'Location',
                              product['location'] ?? 'Unknown'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.inventory, 'Quantity',
                              product['quantity'] ?? 'N/A'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.person, 'Farmer',
                              product['farmer_name'] ?? 'Unknown'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.credit_card, 'Aadhar Number',
                              product['aadhar_number'] ?? 'N/A'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.calendar_today, 'Harvest Date',
                              product['harvest_date'] ?? 'N/A'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // "Add To Cart" Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle Add to Cart action
                      _addToCart(context);
                    },
                    icon: Icon(Icons.shopping_bag, size: 24, color: Colors.green),
                    label: Text(
                      'Add To Cart',
                      style: TextStyle(color: Colors.green),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Action Buttons: Arranged in a Grid Style
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 12.0,
                    childAspectRatio: 2.8,
                    children: [
                      _buildActionButton(
                        context,
                        text: 'Product Video',
                        color: Colors.green[500]!,
                        icon: Icons.video_camera_front_outlined,
                        onPressed: () {
                          _watchVideo(context);
                        },
                      ),
                      _buildActionButton(
                        context,
                        text: 'Chat Now',
                        color: Colors.green[600]!,
                        icon: Icons.chat,
                        onPressed: () {
                          _sendWhatsAppMessage(
                              context, product['mobile_no'] ?? '');
                        },
                      ),
                      _buildActionButton(
                        context,
                        text: 'Call',
                        color: Colors.green[700]!,
                        icon: Icons.phone,
                        onPressed: () {
                          _makePhoneCall(context, product['mobile_no'] ?? '');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add to Cart functionality
  void _addToCart(BuildContext context) {
    // Navigate to the AddToCartPage with the product details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddToCartPage(product: product),
      ),
    );
  }

  // Helper method to build detail rows with icons
  Widget _buildDetailRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green[700],
          size: 28,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Builds an action button with icon and text
  Widget _buildActionButton(
      BuildContext context, {
        required String text,
        required Color color,
        required IconData icon,
        required VoidCallback onPressed,
      }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.green, size: 20),
          label: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.green),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
          ),
        ),
      ),
    );
  }

  // Watch product video
  void _watchVideo(BuildContext context) async {
    final String videoUrl = product['video_url'] ?? '';
    if (videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video URL not available')),
      );
      return;
    }

    final Uri videoUri = Uri.parse(videoUrl);
    if (await canLaunch(videoUri.toString())) {
      await launch(videoUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch video')),
      );
    }
  }

  // Send WhatsApp message
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

  // Make phone call
  void _makePhoneCall(BuildContext context, String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mobile number not available')),
      );
      return;
    }

    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not make a phone call')),
      );
    }
  }
}