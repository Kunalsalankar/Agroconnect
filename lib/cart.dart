// cart.dart

import 'package:flutter/material.dart';

class Cart {
  // Private constructor to prevent external instantiation
  Cart._privateConstructor();

  // Singleton instance
  static final Cart _instance = Cart._privateConstructor();

  // Factory constructor to return the same instance every time
  factory Cart() {
    return _instance;
  }

  // List to store cart items
  final List<Map<String, dynamic>> _items = [];

  // Getter to access cart items
  List<Map<String, dynamic>> get items => _items;

  /// Adds a product to the cart.
  /// If the product already exists, it increments the quantity.
  void addItem(Map<String, dynamic> product) {
    // Check if the product is already in the cart
    int index = _items.indexWhere((item) => item['id'] == product['id']);
    if (index != -1) {
      // If it exists, increase the quantity
      _items[index]['quantity'] += 1;
    } else {
      // If not, add the product with a quantity of 1
      _items.add({...product, 'quantity': 1});
    }
  }

  /// Removes a product from the cart based on its [productId].
  void removeItem(String productId) {
    _items.removeWhere((item) => item['id'] == productId);
  }

  /// Updates the quantity of a specific product in the cart.
  /// If [quantity] is less than or equal to 0, the product is removed from the cart.
  void updateQuantity(String productId, int quantity) {
    int index = _items.indexWhere((item) => item['id'] == productId);
    if (index != -1) {
      _items[index]['quantity'] = quantity;
      if (quantity <= 0) {
        removeItem(productId);
      }
    }
  }

  /// Calculates and returns the total price of all items in the cart.
  double getTotalPrice() {
    double total = 0.0;
    for (var item in _items) {
      // Ensure price is parsed correctly
      double price = 0.0;
      if (item['price'] is int) {
        price = (item['price'] as int).toDouble();
      } else if (item['price'] is double) {
        price = item['price'];
      } else if (item['price'] is String) {
        price = double.tryParse(item['price']) ?? 0.0;
      }
      total += price * (item['quantity'] as int);
    }
    return total;
  }

  /// Clears all items from the cart.
  void clearCart() {
    _items.clear();
  }

  /// Returns the total number of items in the cart.
  int getTotalItems() {
    int totalItems = 0;
    for (var item in _items) {
      totalItems += item['quantity'] as int;
    }
    return totalItems;
  }

  /// Checks if a product is already in the cart.
  bool isInCart(String productId) {
    return _items.any((item) => item['id'] == productId);
  }
}
