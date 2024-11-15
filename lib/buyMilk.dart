import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'cancel.dart';
import 'razorpay_service.dart';
import 'OrderPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for database

class BuyMilkPage extends StatefulWidget {
  final Map<String, dynamic> milkProduct;

  const BuyMilkPage({Key? key, required this.milkProduct}) : super(key: key);

  @override
  _BuyMilkPageState createState() => _BuyMilkPageState();
}

class _BuyMilkPageState extends State<BuyMilkPage> {
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
        builder: (context) => OrderPage(productId: widget.milkProduct['id']),
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
    await _prefs.setString('productName', widget.milkProduct['productName'] ?? '');
    await _prefs.setDouble('price', widget.milkProduct['price']?.toDouble() ?? 0.0);
    await _prefs.setInt('quantity', widget.milkProduct['quantity'] ?? 0);
    await _prefs.setString('farmerName', widget.milkProduct['farmerName'] ?? '');
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
    String priceString = widget.milkProduct['price'].toString();
    priceString = priceString.replaceAll(RegExp(r'[^0-9.]'), '');

    double price = double.tryParse(priceString) ?? 0.0;

    if (price > 0.0) {
      await _storeOrderInFirestore();

      _razorpayService.openCheckout(
        context: context,
        amount: (price * 1).toString(),
        productName: widget.milkProduct['productName'] ?? 'Milk Product',
        productId: widget.milkProduct['id'] ?? '', userName: '', userAddress: '',
      );
    } else {
      debugPrint('Invalid price detected: $priceString');
    }
  }

  Future<void> _storeOrderInFirestore() async {
    String userId = _prefs.getString('userId') ?? 'UnknownUser';

    try {
      await FirebaseFirestore.instance.collection('milk_orders').add({
        'userId': userId,
        'productId': widget.milkProduct['id'],
        'productName': widget.milkProduct['productName'] ?? 'Milk Product',
        'price': widget.milkProduct['price'],
        'quantity': widget.milkProduct['quantity'] ?? 0,
        'farmerName': widget.milkProduct['farmerName'] ?? 'N/A',
        'orderDate': DateTime.now(),
      });

      debugPrint('Order successfully stored in Firestore.');
    } catch (e) {
      debugPrint('Failed to store order in Firestore: $e');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Milk Purchase'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Milk Product Details:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Center(
                child: Hero(
                  tag: 'milk-product-image-${widget.milkProduct['id']}',
                  child: Image.asset(
                    widget.milkProduct['image'] ?? '',
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
              _buildDetail('Product Name', widget.milkProduct['name']),
              _buildDetail('Weekly Price', '₹${widget.milkProduct['priceWeekly']}'),
              _buildDetail('Monthly Price', '₹${widget.milkProduct['priceMonthly']}'),
              _buildDetail('Farmer Name', widget.milkProduct['farmerName']),
              _buildDetail('Mobile Number', widget.milkProduct['mobile_no']),
              SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.payment, size: 28),
                label: Text(
                  'Confirm Purchase',
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
                onPressed: _confirmPurchase,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.cancel, size: 24),
                label: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 18, color: Colors.blue[600]),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueGrey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

