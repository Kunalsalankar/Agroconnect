import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'AddToCartPage.dart'; // Import your cart page
import 'ProductDetailPage.dart'; // Import your product detail page
import 'ProfilePage.dart'; // Import your profile page
import 'transportation_services.dart'; // Import transportation services
import 'AboutUsPage.dart'; // Import about us page
import 'package:url_launcher/url_launcher.dart';
import 'AddNewProduct.dart'; // Import the add new product page
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore
import 'subscription.dart';
import 'adverstiment.dart';
import 'auction.dart';
import 'chat_dashboard.dart';
class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final String username = "username"; // Define your username
  final String farmerName = "farmer_name"; // Define the farmer's name
  final String chatId = "your_chat_id"; // Define the chat room ID

  int _selectedIndex = 0;
  String _searchQuery = "";
  List<Map<String, dynamic>> cartItems = [];

  // Predefined products with unified 'productName' field
  final List<Map<String, dynamic>> predefinedItems = [

    // Add more products as needed
  ];

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> displayedProducts = [];
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  final List<String> categories = ['All', 'Soyabean', 'Gram', 'Tur'];

  @override
  void initState() {
    super.initState();
    _fetchFirestoreProducts();
    _loadCartItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Listener for search bar changes
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  // Fetch products from Firestore
  Future<void> _fetchFirestoreProducts() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot snapshot = await firestore
          .collection('kunu') // Ensure this is the correct collection name
          .orderBy('createdAt', descending: true)
          .get();

      // Convert Firestore documents to Map<String, dynamic>
      List<Map<String, dynamic>> firestoreProducts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'productName': data['productName'] ?? '',
          'price': data['price'] ?? '',
          'quantity': data['quantity'] ?? '',
          'location': data['location'] ?? '',
          'farmerName': data['farmerName'] ?? '',
          'aadharNumber': data['aadharNumber'] ?? '',
          'harvestDate': data['harvestDate'] ?? '',
          'imageUrl': data['imageUrl'] ?? '',
          'createdAt': data['createdAt'] ?? Timestamp.now(),
        };
      }).toList();

      setState(() {
        allProducts = [...predefinedItems, ...firestoreProducts];
        displayedProducts = List.from(allProducts);
      });

      _applyFilters();
    } catch (e) {
      print('Error fetching Firestore products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch products from Firestore')),
      );
    }
  }

  // Load cart items from SharedPreferences
  Future<void> _loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartData = prefs.getString('cart');
    if (cartData != null) {
      setState(() {
        cartItems = List<Map<String, dynamic>>.from(json.decode(cartData));
      });
    }
  }

  // Add product to cart
  Future<void> _addToCart(Map<String, dynamic> product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      cartItems.add(product);
    });

    String cartData = json.encode(cartItems);
    await prefs.setString('cart', cartData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['productName']} added to cart!')),
    );
  }

  // Add new product from AddNewProduct.dart
  void _addNewProduct(Map<String, dynamic> newProduct) {
    setState(() {
      allProducts.insert(0, newProduct);
      displayedProducts = List.from(allProducts);
    });
  }

  // Apply search and category filters
  void _applyFilters() {
    String query = _searchQuery.toLowerCase();
    setState(() {
      displayedProducts = allProducts.where((product) {
        // Category Filtering
        bool matchesCategory = false;
        if (_selectedCategoryIndex == 0) {
          matchesCategory = true; // All categories
        } else {
          String selectedCategory = categories[_selectedCategoryIndex].toLowerCase();
          matchesCategory = product['productName']
              .toString()
              .toLowerCase()
              .contains(selectedCategory) ||
              product['productName']
                  .toString()
                  .toLowerCase()
                  .contains(selectedCategory);
        }

        // Search Filtering
        bool matchesSearch = product['productName']
            .toString()
            .toLowerCase()
            .contains(query) ||
            product['productName']
                .toString()
                .toLowerCase()
                .contains(query);

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  // Filter by category
  void _filterByCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _applyFilters();
    });
  }

  // Navigate to product details page
  void _navigateToProductDetail(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  // Navigate to other pages based on bottom navigation
  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // Already on Home, do nothing
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddToCartPage()),
        );
        break;
      case 2:
        _launchMarketViewUrl();
        break;
    }
  }

  // Launch external URL
  void _launchMarketViewUrl() async {
    const url = 'https://agmarknet.gov.in/';
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
      print('Could not launch $url');
    }
  }

  // Build search bar
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search for product...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // Build category chips
  Widget _buildCategoryChips() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ChoiceChip(
              label: Text(
                categories[index],
                style: TextStyle(
                  color: _selectedCategoryIndex == index
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              selectedColor: Colors.green,
              backgroundColor: Colors.grey[200],
              selected: _selectedCategoryIndex == index,
              onSelected: (bool selected) {
                _filterByCategory(selected ? index : 0);
              },
            ),
          );
        },
      ),
    );
  }

  // Build product list
  Widget _buildProductList() {
    if (displayedProducts.isEmpty) {
      return Center(child: Text('No products found'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: displayedProducts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        childAspectRatio: 0.68, // Adjusted for better height
        crossAxisSpacing: 12, // Horizontal spacing
        mainAxisSpacing: 12, // Vertical spacing
      ),
      itemBuilder: (context, index) {
        final product = displayedProducts[index];
        return GestureDetector(
          onTap: () => _navigateToProductDetail(product),
          child: Card(
            elevation: 5,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(15)),
                    child: _buildProductImage(product),
                  ),
                ),
                // Product Details
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product['productName'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      // Price
                      Text(
                        product['price'] ?? '',
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                      SizedBox(height: 2),
                      // Rating
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            product['location'] ?? '',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Add to Cart Button
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: SizedBox(
                    width: double.infinity,
                    height: 5, // Fixed height for consistency

                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build product image
  Widget _buildProductImage(Map<String, dynamic> product) {
    String? imageUrl = product['imageUrl'];
    String? photo = product['photo'];

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
      );
    } else if (photo != null && photo.isNotEmpty) {
      return Image.asset(
        photo,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
      );
    } else {
      return Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
    }
  }

  // Build Drawer
  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green[600],
            ),
            child: Text(
              'Agroconnect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.ads_click), // Updated icon for advertisement
            title: Text('Advertisement'), // Updated title to 'Advertisement'
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Advertisement()), // Make sure this points to your advertisement screen
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.subscriptions),
            title: Text('Subscription'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubscriptionPage()),
              );
            },
          ),


          ListTile(
            leading: Icon(Icons.monetization_on_outlined),
            title: Text('Auction'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Auction()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.delivery_dining),
            title: Text('Transportation Services'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TransportationServicesPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agroconnect'),
        backgroundColor: Colors.green[600],
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final newProduct = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewProduct(),
                ),
              );
              if (newProduct != null && newProduct is Map<String, dynamic>) {
                _addNewProduct(newProduct);
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildSearchBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildCategoryChips(),
          ),
          SizedBox(height: 10),
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Market View',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: _onBottomNavItemTapped,
      ),
    );
  }
}