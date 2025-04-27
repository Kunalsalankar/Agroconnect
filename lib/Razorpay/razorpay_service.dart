import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../order_page/MyOrderPage.dart';

class RazorpayService {
  late Razorpay _razorpay;
  BuildContext? _context;

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

  void openCheckout({
    required BuildContext context,
    required String amount,
    required String productName,
    required String productId,
    required String userName,
    required String userAddress,
  }) {
    _context = context;
    this.amount = amount;
    this.productName = productName;
    this.productId = productId;
    this.userName = userName;
    this.userAddress = userAddress;

    var options = {
      'key': 'rzp_test_UoJM3SsuEeyGjP',
      'amount': (double.parse(amount) * 1).toInt(), // Amount is in paise (1 INR = 100 paise)
      'name': 'Product Purchase',
      'description': 'Payment for $productName',
      'prefill': {
        'contact': '9876543210',  // You can replace with the actual contact number
        'email': 'test@razorpay.com' // You can replace with the actual email
      },
      'external': {
        'wallets': ['paytm'] // Example external wallet options, you can customize this list
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

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final orderId = FirebaseFirestore.instance.collection('order_id').doc(userId).collection('userOrders').doc().id;

    // Save the order data in Firestore
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
      'quantity': 1,  // Assuming quantity is 1, you can adjust this based on the actual value
      'userName': userName,
      'userAddress': userAddress,
      'timestamp': FieldValue.serverTimestamp(),
    });

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
                    Navigator.pop(context); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyOrdersPage(), // Redirect to orders page
                      ),
                    );
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

    if (_context != null) {
      showDialog(
        context: _context!,
        builder: (context) {
          return AlertDialog(
            title: Text("Payment Failed"),
            content: Text("Error Code: ${response.code}\n${response.message}"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Retry"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Cancel"),
              ),
            ],
          );
        },
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet: ${response.walletName}");
    // Handle external wallet payment response
  }

  void dispose() {
    _razorpay.clear();
  }
}
