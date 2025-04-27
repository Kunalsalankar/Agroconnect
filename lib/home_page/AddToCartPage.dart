import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googlemerr/chatting/ChartOrderPage.dart';
import 'buy_now.dart';

class AddToCartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
        backgroundColor: Colors.green[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Your cart is empty.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          // Calculate total price
          double totalPrice = 0;
          snapshot.data!.docs.forEach((doc) {
            Map<String, dynamic> product = doc.data() as Map<String, dynamic>;
            double price = double.tryParse(product['price']?.toString() ?? '0') ?? 0;
            int quantity = int.tryParse(product['quantity']?.toString() ?? '1') ?? 1;
            totalPrice += price * quantity;
          });

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(10),
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> product = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundImage: product['imageUrl'] != null
                              ? NetworkImage(product['imageUrl'])
                              : AssetImage('assets/images/default_product.png') as ImageProvider,
                          radius: 30,
                        ),
                        title: Text(
                          product['productName'] ?? 'Unnamed Product',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text('Price: ₹${product['price'] ?? 'N/A'}', style: TextStyle(fontSize: 14)),
                            SizedBox(height: 5),
                            Text('Quantity: ${product['quantity'] ?? 'N/A'}', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .collection('cart')
                                .doc(doc.id)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Item removed from cart')),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.monetization_on, size: 28),
                      label: Text(
                        'Buy Now',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[600]),
                      ),
                      onPressed: () {
                        // Pass total price and other necessary details to BuyNowPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartOrderPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        shadowColor: Colors.blueAccent.withOpacity(0.5),
                        elevation: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}