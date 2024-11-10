import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'MyPost.dart';
import 'ProductDetailPage.dart';
import 'preorder_page.dart';
import 'edit_advertisement.dart';
import 'product.dart';

class Advertisement extends StatefulWidget {
  @override
  _AdvertisementState createState() => _AdvertisementState();
}

class _AdvertisementState extends State<Advertisement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Stream<QuerySnapshot> fetchAdvertisements() {
    return FirebaseFirestore.instance.collection('ayush').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advertisement'),
        backgroundColor: Colors.green[600],
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPost()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for product...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ayush')
                  .orderBy('uploadDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error fetching advertisements.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No advertisements available.'));
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final productName = (data['productName'] ?? '').toLowerCase();
                  return productName.contains(_searchQuery);
                }).toList();

                return ListView(
                  padding: EdgeInsets.all(8),
                  children: filteredDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return AdvertisementCard(data: data, docId: doc.id);
                  }).toList(),
                );
              },
            ),
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

  void _deletePost(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('ayush').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Advertisement deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete advertisement')),
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

  bool _isCurrentUserOwner() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && data['userId'] == currentUser.uid;
  }

  bool _isEditAllowed() {
    final uploadTimestamp = data['uploadDate'] as Timestamp;
    final uploadTime = uploadTimestamp.toDate();
    final currentTime = DateTime.now();
    final difference = currentTime.difference(uploadTime).inMinutes;
    return difference <= 5;
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
                if (_isCurrentUserOwner())
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
                        if (_isEditAllowed())
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
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Background color for Preorder
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreorderPage(productData: data),
                        ),
                      );
                    },
                    child: Text(
                      'Preorder',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Background color for Chat Now
                    ),
                    onPressed: () => _sendWhatsAppMessage(context, data['contactNumber'] ?? ''),
                    child: Text(
                      'Chat Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Background color for Call Now
                    ),
                    onPressed: () => _makePhoneCall(context, data['contactNumber'] ?? ''),
                    child: Text(
                      'Call Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}