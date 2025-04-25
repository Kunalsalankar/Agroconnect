import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AdvRazorpayPage extends StatefulWidget {
  final double amount; // Amount in INR (not paise)
  final String productName;
  final String contact;
  final String email;

  AdvRazorpayPage({
    required this.amount,
    required this.productName,
    required this.contact,
    required this.email,
  });

  @override
  _AdvRazorpayPageState createState() => _AdvRazorpayPageState();
}

class _AdvRazorpayPageState extends State<AdvRazorpayPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Navigator.pop(context, true); // Indicate successful payment
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(context, false); // Indicate failed payment
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Navigator.pop(context, false); // Indicate failed payment
  }

  void _makePayment() {
    // Convert amount to paise (1 INR = 100 paise)
    final priceInPaise = (widget.amount * 100).toInt();

    var options = {
      'key': 'rzp_test_UoJM3SsuEeyGjP', // Replace with your Razorpay Key
      'amount': priceInPaise, // Amount in paise
      'name': widget.productName, // Product name
      'description': 'Preorder Payment',
      'prefill': {
        'contact': widget.contact, // Contact
        'email': widget.email, // Email
      },
      'theme': {
        'color': '#3399cc', // Razorpay UI color
      },
    };

    try {
      _razorpay.open(options); // Open Razorpay payment gateway
    } catch (e) {
      print("Error in opening payment gateway: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _makePayment,
          child: Text('Pay Now'),
        ),
      ),
    );
  }
}
