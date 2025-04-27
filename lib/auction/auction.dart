import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auction/AuctionPost.dart';
import '../auction/AuctionDetail.dart';

class Auction extends StatefulWidget {
  @override
  _AuctionState createState() => _AuctionState();
}

class _AuctionState extends State<Auction> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> displayedItems = [];
  String filter = 'All'; // Options: All, Incoming, Live, Ended

  @override
  void initState() {
    super.initState();
    fetchAllItems();
  }

  void fetchAllItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('auctions').get();
    setState(() {
      allItems = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
      _applyFilters();
    });
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    DateTime now = DateTime.now();

    setState(() {
      displayedItems = allItems.where((item) {
        bool matchesProductName = item['productName']?.toLowerCase().contains(query) ?? false;
        bool matchesLocation = item['location']?.toLowerCase().contains(query) ?? false;
        bool matchesSearch = matchesProductName || matchesLocation;

        DateTime? startDate = item['startDate'] != null ? (item['startDate'] as Timestamp).toDate() : null;
        DateTime? endDate = item['endDate'] != null ? (item['endDate'] as Timestamp).toDate() : null;

        // Filter based on auction status
        if (filter == 'Incoming') {
          return matchesSearch && (startDate != null && startDate.isAfter(now));
        } else if (filter == 'Live') {
          return matchesSearch && (startDate != null && endDate != null && startDate.isBefore(now) && endDate.isAfter(now));
        } else if (filter == 'Ended') {
          return matchesSearch && (endDate != null && endDate.isBefore(now));
        }
        return matchesSearch; // Default to showing all if 'All' is selected
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auctions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AuctionPost()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by Product or Location',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.green[600]),
                      onPressed: _applyFilters,
                    ),
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFilterButton('All'),
                    _buildFilterButton('Incoming'),
                    _buildFilterButton('Live'),
                    _buildFilterButton('Ended'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: displayedItems.length,
              itemBuilder: (context, index) {
                return AuctionCard(data: displayedItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title) {
    bool isSelected = filter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          filter = title;
        });
        _applyFilters();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[600] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class AuctionCard extends StatelessWidget {
  final Map<String, dynamic> data;

  AuctionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final startDate = data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : null;
    final endDate = data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuctionDetail(auctionId: data['id']),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              data['imageUrl'] != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  data['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.image, size: 80, color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                data['productName'] ?? 'Unknown Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 4),
              Text(
                'Base Price: Rs ${data['basePrice'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              Text(
                'Bid Increment: Rs ${data['bidIncrement'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              Text(
                'Quantity: ${data['quantity'] ?? 'N/A'} kg',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              Text(
                'Location: ${data['location'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                startDate != null ? 'Start Date: ${dateFormat.format(startDate)}' : 'Start Date: N/A',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              Text(
                endDate != null ? 'End Date: ${dateFormat.format(endDate)}' : 'End Date: N/A',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}