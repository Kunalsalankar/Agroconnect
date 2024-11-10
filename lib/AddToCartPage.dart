import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddToCartPage extends StatefulWidget {
  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  List<Map<String, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems(); // Load cart items when the page is initialized
  }

  /// Loads cart items from SharedPreferences
  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartData = prefs.getString('cart');
    if (cartData != null) {
      setState(() {
        cartItems = List<Map<String, dynamic>>.from(json.decode(cartData));
      });
    }
  }

  /// Saves cart items back to SharedPreferences
  Future<void> _saveCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', json.encode(cartItems));
  }

  /// Clears the entire cart
  Future<void> _clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cartItems.clear(); // Clear the cart list in the app
    });
    await prefs.remove('cart'); // Remove cart from local storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cart cleared!')),
    );
  }

  /// Removes a single item from the cart
  Future<void> _removeItem(int index) async {
    setState(() {
      cartItems.removeAt(index); // Remove the item from the list
    });
    await _saveCartItems(); // Save the updated list to SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Item removed!')),
    );
  }

  /// Handles the "Buy Now" button press
  void _buyNow() {
    // Implement your buy now functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proceeding to purchase...')),
    );
  }

  /// Updates the cart to prevent duplicate items by increasing the quantity
  void _addOrUpdateItem(Map<String, dynamic> newItem) {
    final index = cartItems.indexWhere((item) => item['productId'] == newItem['productId']);
    if (index >= 0) {
      // If the item already exists, update the quantity
      setState(() {
        cartItems[index]['quantity'] += newItem['quantity'];
      });
    } else {
      // Add new item if it doesn't exist
      setState(() {
        cartItems.add(newItem);
      });
    }
    _saveCartItems(); // Save the updated list to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        backgroundColor: Colors.green[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearCart, // Clear the cart
            tooltip: 'Clear Cart',
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(fontSize: 18),
        ),
      )
          : Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: ListView.builder(
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final item = cartItems[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: AssetImage(item['photo'] ?? 'assets/files/default.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  item['productName'] ?? 'Unknown Product',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Price: ₹${item['price']} | Quantity: ${item['quantity']}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeItem(index),
                  tooltip: 'Remove Item',
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10.0),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: cartItems.isEmpty ? null : _buyNow,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text(
            'Buy Now',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
