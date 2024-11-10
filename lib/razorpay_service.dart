import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'MyOrderPage.dart';

class RazorpayService {
  late Razorpay _razorpay;
  BuildContext? _context; // Store context

  // Store the order details for later use
  late String amount;
  late String productName;
  late String productId;
  late String userName;
  late String userAddress;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Accept context as a parameter and store it for later use
  void openCheckout({
    required BuildContext context, // Pass context from widget
    required String amount, // Amount
    required String productName, // Product name
    required String productId, // Product ID
    required String userName, // User's name
    required String userAddress, // User's address
  }) {
    _context = context; // Store context

    // Store values for later use
    this.amount = amount;
    this.productName = productName;
    this.productId = productId;
    this.userName = userName;
    this.userAddress = userAddress;

    var options = {
      'key': 'rzp_test_GcZZFDPP0jHtC4', // Replace with your Razorpay API Key
      'amount': (double.parse(amount) * 100).toInt(), // Amount in paise
      'name': 'Product Purchase',
      'description': 'Payment for $productName',
      'prefill': {'contact': '9876543210', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("Payment Success: ${response.paymentId}");

    // Retrieve user ID from FirebaseAuth
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Save order details to Firestore in the "order_id" collection
    final orderId = FirebaseFirestore.instance.collection('order_id').doc(userId).collection('userOrders').doc().id; // Unique order ID

    await FirebaseFirestore.instance.collection('order_id')
        .doc(userId)
        .collection('userOrders')
        .doc(orderId)
        .set({
      'paymentStatus': 'Success',
      'paymentId': response.paymentId,
      'amountPaid': amount,
      'productId': productId,
      'productName': productName,
      'quantity': 1, // Assuming quantity is 1 for simplicity; you can modify as needed
      'userName': userName,
      'userAddress': userAddress,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Show confirmation dialog after successful payment
    if (_context != null) {
      showDialog(
        context: _context!,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyOrdersPage(),
                      ),
                    ); // Navigate to MyOrdersPage
                  },
                  child: Text(
                    'View My Orders',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Payment Error: ${response.code} | ${response.message}");
    // Handle payment failure, e.g., show error message
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet: ${response.walletName}");
    // Handle external wallet payments
  }

  void dispose() {
    _razorpay.clear(); // Clean up
  }
}
