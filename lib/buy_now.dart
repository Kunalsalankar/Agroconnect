import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'cancel.dart';
import 'razorpay_service.dart';
import 'OrderPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for database

class BuyNowPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const BuyNowPage({Key? key, required this.product}) : super(key: key);

  @override
  _BuyNowPageState createState() => _BuyNowPageState();
}

class _BuyNowPageState extends State<BuyNowPage> {
  final RazorpayService _razorpayService = RazorpayService();
  bool isOrderInfoFilled = false;
  late SharedPreferences _prefs;

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeLocalStorage();
  }

  void _initializeLocalStorage() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _fillOrderDetails() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(productId: widget.product['id']),
      ),
    );

    if (result == true) {
      setState(() {
        isOrderInfoFilled = true;
      });
      _saveOrderDetailsLocally();
    }
  }

  void _saveOrderDetailsLocally() async {
    await _prefs.setString('productName', widget.product['productName'] ?? '');
    await _prefs.setDouble('price', widget.product['price']?.toDouble() ?? 0.0);
    await _prefs.setInt('quantity', widget.product['quantity'] ?? 0);
    await _prefs.setString('farmerName', widget.product['farmerName'] ?? '');
  }

  void _confirmPurchase() {
    if (!isOrderInfoFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in your information first.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Purchase Successful',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Your purchase has been confirmed. Proceed to payment.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _proceedToPayment();
                },
                child: Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 18, color: Colors.purple),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _proceedToPayment() async {
    String priceString = widget.product['price'].toString();
    priceString = priceString.replaceAll(RegExp(r'[^0-9.]'), '');

    double price = double.tryParse(priceString) ?? 0.0;

    if (price > 0.0) {
      await _storeOrderInFirestore();

      _razorpayService.openCheckout(
        context: context,
        amount: (price * 1).toString(),
        productName: widget.product['productName'] ?? 'Product',
        productId: widget.product['id'] ?? '', userName: '', userAddress: '',
      );
    } else {
      debugPrint('Invalid price detected: $priceString');
    }
  }

  Future<void> _storeOrderInFirestore() async {
    String userId = _prefs.getString('userId') ?? 'UnknownUser';

    try {
      await FirebaseFirestore.instance.collection('order_id').add({
        'userId': userId,
        'productId': widget.product['id'],
        'productName': widget.product['productName'] ?? 'Product Name',
        'price': widget.product['price'],
        'quantity': widget.product['quantity'] ?? 0,
        'farmerName': widget.product['farmerName'] ?? 'N/A',
        'orderDate': DateTime.now(),
      });

      debugPrint('Order successfully stored in Firestore.');
    } catch (e) {
      debugPrint('Failed to store order in Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Purchase'),
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
              Center(
                child: Hero(
                  tag: 'product-image-${widget.product['id']}',
                  child: Image.network(
                    widget.product['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.product['productName'] ?? 'Product Name',
                style: TextStyle(fontSize: 22, color: Colors.green[900]),
              ),
              SizedBox(height: 10),
              Text(
                'Price: ₹${widget.product['price']}',
                style: TextStyle(fontSize: 18, color: Colors.green[700]),
              ),
              SizedBox(height: 10),
              Text(
                'Quantity: ${widget.product['quantity'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18, color: Colors.green[700]),
              ),
              SizedBox(height: 10),
              Text(
                'Farmer: ${widget.product['farmerName'] ?? 'N/A'}',
                style: TextStyle(fontSize: 18, color: Colors.green[700]),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.edit, size: 24),
                label: Text(
                  'Fill Details',
                  style: TextStyle(fontSize: 18, color: Colors.green[600]),
                ),
                onPressed: _fillOrderDetails,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.payment, size: 28),
                label: Text(
                  'Confirm Purchase',
                  style: TextStyle(fontSize: 20, color: Colors.green[600]),
                ),
                onPressed: _confirmPurchase,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.cancel, size: 24),
                label: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 18, color: Colors.green[600]),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CancelPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
