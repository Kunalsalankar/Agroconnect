import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'AddToCartPage.dart';
class MilkProductPage extends StatelessWidget {
  final Map<String, dynamic> product;

  MilkProductPage({required this.product});

  @override
  Widget build(BuildContext context) {
    // Validate necessary fields
    if (!product.containsKey('id') ||
        !product.containsKey('farmer_name') ||
        !product.containsKey('aadhar_number')) {
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
              title: Text(
                product['name'] ?? 'Milk Product Detail',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Hero(
                tag: 'product-image-${product['id']}',
                child: Image.asset(
                  product['image'],
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
                          _buildDetailRow(Icons.price_change, 'Weekly Price',
                              product['priceWeekly'] ?? 'N/A'),
                          SizedBox(height: 12),
                          _buildDetailRow(Icons.price_change, 'Monthly Price',
                              product['priceMonthly'] ?? 'N/A'),
                          SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.person,
                            'Farmer Name',
                            product['farmer_name'] ?? 'N/A',
                          ),
                          SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.credit_card,
                            'Aadhar No',
                            product['aadhar_number'] ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Add to Cart Button
                  ElevatedButton.icon(
                    icon: Icon(Icons.shopping_cart, size: 28),
                    label: Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    onPressed: () {
                      // Navigate to AddToCartPage and pass the product data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddToCartPage(product: product),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadowColor: Colors.orangeAccent.withOpacity(0.5),
                      elevation: 8,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Row with Call Now and Chat Now Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Call Now Button
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
                            final Uri url = Uri(
                              scheme: 'tel',
                              path: product['mobile_no'] ?? '',
                            );
                            launchUrl(url);
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
                      // Chat Now Button
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
                          onPressed: () {
                            // Implement chat feature
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.green),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
