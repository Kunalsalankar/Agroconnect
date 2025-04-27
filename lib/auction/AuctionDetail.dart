import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AuctionDetail extends StatefulWidget {
  final String auctionId;

  AuctionDetail({required this.auctionId});

  @override
  _AuctionDetailState createState() => _AuctionDetailState();
}

class _AuctionDetailState extends State<AuctionDetail> {
  final TextEditingController _bidController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? auctionData;
  DateTime? startDate;
  DateTime? endDate;
  String? currentUserId;
  String? currentUsername;
  String? winningUsername;

  @override
  void initState() {
    super.initState();
    _getCurrentUserData();
    _fetchAuctionDetails();
  }

  Future<void> _getCurrentUserData() async {
    currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUserId).get();
      setState(() {
        currentUsername = userDoc['username'];
      });
    }
  }

  Future<void> _fetchAuctionDetails() async {
    DocumentSnapshot auctionDoc = await _firestore.collection('auctions').doc(widget.auctionId).get();
    if (auctionDoc.exists) {
      setState(() {
        auctionData = auctionDoc.data() as Map<String, dynamic>?;
        startDate = (auctionData?['startDate'] as Timestamp?)?.toDate();
        endDate = (auctionData?['endDate'] as Timestamp?)?.toDate();
      });
      _checkAuctionWinner();  // Check winner after fetching auction details
    }
  }

  Future<void> _placeBid() async {
    final bidAmount = double.tryParse(_bidController.text);
    final basePrice = auctionData?['basePrice'] ?? 0;

    if (bidAmount == null || bidAmount < basePrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a bid equal to or higher than the base price.')),
      );
      return;
    }

    if (currentUsername == null || currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User information not available.')),
      );
      return;
    }

    try {
      await _firestore.collection('auctions').doc(widget.auctionId).collection('bids').add({
        'username': currentUsername,
        'userId': currentUserId,
        'bidAmount': bidAmount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _bidController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bid placed successfully!')),
      );

      // Recheck for the winner after placing a bid
      _checkAuctionWinner();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place bid. Please try again.')),
      );
    }
  }

  Future<void> _checkAuctionWinner() async {
    if (DateTime.now().isAfter(endDate!)) {
      var bidQuery = await _firestore
          .collection('auctions')
          .doc(widget.auctionId)
          .collection('bids')
          .orderBy('bidAmount', descending: true)
          .limit(1)
          .get();

      if (bidQuery.docs.isNotEmpty) {
        var winningBid = bidQuery.docs.first;
        setState(() {
          winningUsername = winningBid['username'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final isAuctionLive = startDate != null && endDate != null &&
        DateTime.now().isAfter(startDate!) && DateTime.now().isBefore(endDate!);

    if (auctionData == null || startDate == null || endDate == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Auction Detail'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(auctionData?['productName'] ?? 'Auction Detail'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            auctionData!['imageUrl'] != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                auctionData!['imageUrl'],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
                : Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[300]!,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.image,
                size: 100,
                color: Colors.green[600],
              ),
            ),
            SizedBox(height: 16),
            Text(
              auctionData!['productName'] ?? 'Unknown Product',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green[800]),
            ),
            SizedBox(height: 8),
            _buildDetailRow('Base Price:', 'Rs ${auctionData!['basePrice'] ?? 'N/A'}'),
            _buildDetailRow('Bid Increment:', 'Rs ${auctionData!['bidIncrement'] ?? 'N/A'}'),
            _buildDetailRow('Quantity:', '${auctionData!['quantity'] ?? 'N/A'} kg'),
            _buildDetailRow('Location:', auctionData!['location'] ?? 'N/A'),
            _buildDetailRow('Farmer:', auctionData!['farmerName'] ?? 'N/A'),
            _buildDetailRow('Farmer Contact:', auctionData!['farmerMobile'] ?? 'N/A'),
            SizedBox(height: 20),
            Text(
              'Auction Starts: ${dateFormat.format(startDate!)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Auction Ends: ${dateFormat.format(endDate!)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildAuctionStatus(isAuctionLive),
            SizedBox(height: 20),
            _buildBidList(),
            // Show the winning message only if the auction has ended and bids were placed
            if (DateTime.now().isAfter(endDate!) && winningUsername != null) ...[
              SizedBox(height: 20),
              _buildWinningMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildAuctionStatus(bool isAuctionLive) {
    if (DateTime.now().isBefore(startDate!)) {
      return _statusContainer(
        message: 'Auction is not live!',
        backgroundColor: Colors.white,
        textColor: Colors.orange[800]!,
      );
    } else if (isAuctionLive) {
      return Column(
        children: [
          _statusContainer(
            message: 'Auction is live! Place your bid below:',
            backgroundColor: Colors.white,
            textColor: Colors.green[800]!,
          ),
          SizedBox(height: 10),
          _bidInput(),
        ],
      );
    } else {
      return _statusContainer(
        message: 'Auction has ended!',
        backgroundColor: Colors.white,
        textColor: Colors.red[800]!,
      );
    }
  }

  Widget _statusContainer({required String message, required Color backgroundColor, required Color textColor}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _bidInput() {
    return Column(
      children: [
        TextField(
          controller: _bidController,
          decoration: InputDecoration(
            labelText: 'Enter your bid amount',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _placeBid,
          child: Text('Place Bid'),
        ),
      ],
    );
  }

  Widget _buildBidList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('auctions')
          .doc(widget.auctionId)
          .collection('bids')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No bids placed yet.');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var bidDoc = snapshot.data!.docs[index];
            return ListTile(
              title: Text('${bidDoc['username']} placed a bid of Rs ${bidDoc['bidAmount']}'),
              subtitle: Text('${DateFormat('dd MMM yyyy, HH:mm').format((bidDoc['timestamp'] as Timestamp).toDate())}'),
            );
          },
        );
      },
    );
  }

  Widget _buildWinningMessage() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Congratulations! The auction winner is: $winningUsername',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
        textAlign: TextAlign.center,
      ),
    );
  }
}