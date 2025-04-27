import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preorder Products'),
        backgroundColor: Colors.green[600],
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('samyak').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No preorders found.'));
          }
          final preorders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: preorders.length,
            itemBuilder: (context, index) {
              final preorder = preorders[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListTile(
                      title: Text(preorder['productName'],),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${preorder['name']}'),
                          Text('Quantity: ${preorder['quantity']}'),
                          Text('Adress: ${preorder['deliveryAddress']}'),
                          Text('Delivery Date: ${preorder['preferredDeliveryDate'].toDate()}'),

                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
