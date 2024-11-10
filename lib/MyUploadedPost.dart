import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'edit_advertisement.dart';
import 'preorder_page.dart';

class MyUploadedPost extends StatefulWidget {
  @override
  _MyUploadedPostState createState() => _MyUploadedPostState();
}

class _MyUploadedPostState extends State<MyUploadedPost> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> _advertisementStream;
  late Stream<QuerySnapshot> _productStream; // Stream for user's products
  bool isLoading = true;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid; // Get current user ID
    _advertisementStream = FirebaseFirestore.instance
        .collection('ayush') // 'ayush' collection for advertisements
        .where('userId', isEqualTo: userId) // Filter by userId for advertisements
        .snapshots(); // Fetch advertisements posted by the current user

    _productStream = FirebaseFirestore.instance
        .collection('kunu') // 'kunu' collection where products are stored
        .where('userId', isEqualTo: userId) // Filter by userId
        .snapshots(); // Stream of user's products
  }

  // UI for displaying advertisements with safety check for data
  Widget _buildProductCard(DocumentSnapshot product) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displaying the product image with safety check for null
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product['imageUrl'] != null && product['imageUrl'] != ''
                  ? Image.network(
                product['imageUrl'],
                fit: BoxFit.cover,
                height: 150,
                width: double.infinity,
              )
                  : Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            ),
            SizedBox(height: 10),
            // Product name with a safety check for null
            Text(
              product['productName'] ?? 'No name available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 5),
            // Product price with a safety check for null
            Text(
              'Price: Rs ${product['price'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            // Product quantity with a safety check for null
            Text(
              'Quantity: ${product['quantity'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            // Product description or any additional information
            Text(
              'Location: ${product['location'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Harvest Date: ${product['harvestDate'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 15),
            // Popup menu for Edit and Delete options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                ElevatedButton(
                  onPressed: () => _deleteProduct(context, product.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Green background
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 128),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Edit product functionality
  void _editProduct(BuildContext context, DocumentSnapshot product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAdvertisement(
          docId: product.id,
          data: product.data() as Map<String, dynamic>,
        ),
      ),
    );
  }

  // Delete product functionality
  void _deleteProduct(BuildContext context, String productId) async {
    try {
      await FirebaseFirestore.instance.collection('kunu').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product')),
      );
    }
  }

  // UI for displaying advertisements with safety check for data
  Widget _buildAdvertisementCard(Map<String, dynamic> data, String docId) {
    return AdvertisementCard(data: data, docId: docId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Uploaded Posts'),
        backgroundColor: Colors.green[800],
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          // Section for user's product details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Home Page - Your Products',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ),
          // StreamBuilder for displaying the user's products
          StreamBuilder<QuerySnapshot>(
            stream: _productStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading products'));
              }
              final products = snapshot.data?.docs ?? [];
              if (products.isEmpty) {
                return Center(child: Text('No products available.'));
              }
              return Column(
                children: products.map((doc) {
                  return _buildProductCard(doc);
                }).toList(),
              );
            },
          ),

          // Section for advertisements
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Advertisement Posts',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _advertisementStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading posts'));
              }
              final posts = snapshot.data?.docs ?? [];
              if (posts.isEmpty) {
                return Center(child: Text('No advertisements available.'));
              }

              return Column(
                children: posts.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildAdvertisementCard(data, doc.id);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AdvertisementCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  AdvertisementCard({required this.data, required this.docId});

  String _formatDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('MMM d, yyyy - hh:mm a').format(dateTime);
  }

  void _deletePost(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('ayush').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post')),
      );
    }
  }

  void _editPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAdvertisement(
          docId: docId,
          data: data,
        ),
      ),
    );
  }

  bool _canEditPost(Timestamp uploadDate) {
    final currentTime = DateTime.now();
    final postTime = uploadDate.toDate();
    return currentTime.difference(postTime).inMinutes <= 5;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: data['profileImageUrl'] != null
                          ? NetworkImage(data['profileImageUrl'])
                          : null,
                      radius: 24,
                      backgroundColor: Colors.grey[300],
                      child: data['profileImageUrl'] == null
                          ? Icon(Icons.person, color: Colors.grey[600], size: 24)
                          : null,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['farmerName'] ?? 'Unknown Farmer',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            data['uploadDate'] != null
                                ? _formatDate(data['uploadDate'])
                                : 'Date not available',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editPost(context);
                        } else if (value == 'delete') {
                          _deletePost(context);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          if (_canEditPost(data['uploadDate']))
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
                SizedBox(height: 18),
                data['imageUrl'] != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    data['imageUrl'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  data['productName'] ?? 'Unknown Product',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text('Price: ${data['price'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
                Text('Quantity: ${data['quantity'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
                Text('Location: ${data['location'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
                Text('Farmer: ${data['farmerName'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
                Text('Contact No: ${data['contactNumber'] ?? 'N/A'}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  'Harvest Date: ${data['harvestDate'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
              ],
            ),
            ),
        );
    }
}