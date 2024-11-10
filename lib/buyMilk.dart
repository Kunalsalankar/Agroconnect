import 'package:flutter/material.dart';
import 'confirmMilk.dart';

class BuyMilkPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const BuyMilkPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Milk'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'You are buying:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Product Image
              Center(
                child: Hero(
                  tag: 'product-image-${product['id']}',
                  child: Image.asset(
                    product['image'],
                    fit: BoxFit.cover,
                    height: 200,
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
              SizedBox(height: 20),

              // Product Information
              Text(
                product['name'] ?? 'Milk Product Name',
                style: TextStyle(fontSize: 22, color: Colors.green[900]),
              ),
              SizedBox(height: 10),

              // Weekly and Monthly Prices
              Text(
                'Weekly Price: ${product['priceWeekly'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18, color: Colors.green[700]),
              ),
              SizedBox(height: 10),
              Text(
                'Monthly Price: ${product['priceMonthly'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18, color: Colors.green[700]),
              ),
              SizedBox(height: 10),
              Text(
                'Farmer: ${product['farmer_name'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 18, color: Colors.green[700]),
              ),
              SizedBox(height: 20),

              // Confirm Purchase Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfirmMilkPage(product: product),
                    ),
                  );
                },
                icon: Icon(Icons.check_circle, size: 30, color: Colors.white),
                label: Text(
                  'Proceed to Confirm',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}