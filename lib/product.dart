import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user ID from Firebase Authentication
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Preorder Products'),
          backgroundColor: Colors.green[600],
        ),
        body: Center(
          child: Text('Please log in to see your preorders.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Preorder Products'),
        backgroundColor: Colors.green[600],
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('samyak')
            .where('userId', isEqualTo: currentUser.uid) // Filter by userId
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No preorders found for this user.'));
          }

          final preorders = snapshot.data!.docs;
          return ListView.builder(
            itemCount: preorders.length,
            itemBuilder: (context, index) {
              final preorder = preorders[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adds margin around each preorder box
                padding: EdgeInsets.all(16), // Padding inside the white box
                decoration: BoxDecoration(
                  color: Colors.white, // White background box
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero, // Removes extra padding inside ListTile
                  title: Text(
                    preorder['productName'] ?? 'No Product Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${preorder['name'] ?? 'N/A'}'),
                      Text('Quantity: ${preorder['quantity'] ?? 'N/A'}'),
                      Text(
                        'Delivery Date: ${preorder['preferredDeliveryDate'] != null ? preorder['preferredDeliveryDate'].toDate().toString() : 'N/A'}',
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Show a confirmation dialog before deleting
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Deletion'),
                          content: Text('Are you sure you want to delete this preorder?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('samyak')
                              .doc(preorder.id)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Preorder deleted successfully')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete preorder')),
                          );
                        }
                      }
                    },
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
