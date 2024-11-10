import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'milkproductpage.dart';
import 'home_view.dart';
import 'AddServiceProduct.dart'; // Import the AddServiceProduct file

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // Predefined products
  final List<Map<String, String>> predefinedItems = [
    {
      'id': '1',
      'name': 'Milk 1L',
      'image': 'assets/files/milk.jpg',
      'priceWeekly': '280Rs Weekly',
      'priceMonthly': '1200Rs Monthly',
      'mobile_no': '9145393757',
      'farmer_name': 'Ram Sharma',
      'aadhar_number': '1234-2345-1234',
    },
    {
      'id': '2',
      'name': 'Cheese 500g',
      'image': 'assets/files/cheese.jpeg',
      'priceWeekly': '1000Rs Weekly',
      'priceMonthly': '2500Rs Monthly',
      'mobile_no': '9730693440',
      'farmer_name': 'Virat Kholi',
      'aadhar_number': '1234-2345-1231',
    },
    {
      'id': '3',
      'name': 'Butter 250g',
      'image': 'assets/files/butter.jpeg',
      'priceWeekly': '300Rs Weekly',
      'priceMonthly': '1200Rs Monthly',
      'mobile_no': '9370482365',
      'farmer_name': 'Ram Vaidya',
      'aadhar_number': '1234-2345-1239',
    },
    {
      'id': '4',
      'name': 'Milk 2L',
      'image': 'assets/files/milk2.jpeg', // Ensure the asset path is correct
      'priceWeekly': '400Rs Weekly',
      'priceMonthly': '2400Rs Monthly',
      'mobile_no': '7776884378',
      'farmer_name': 'Virat Sharma',
      'aadhar_number': '1234-2345-1230',
    },
  ];

  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> displayedItems = [];
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  final List<String> categories = ['All', 'Milk', 'Cheese', 'Butter'];

  @override
  void initState() {
    super.initState();
    // Initialize with predefined items
    allItems = predefinedItems.map((item) => Map<String, dynamic>.from(item)).toList();
    _fetchProducts(); // Fetch products from Firestore
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  // Fetch products from Firestore
  Future<void> _fetchProducts() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot snapshot = await firestore
          .collection('products')
          .orderBy('timestamp', descending: true)
          .get();

      // Store fetched products into allItems
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID to the data
        allItems.add(data);
      }

      setState(() {
        displayedItems = List.from(allItems); // Update displayedItems to show all items
      });
    } catch (e) {
      print('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch products')),
      );
    }
  }

  // Apply search and category filters
  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      displayedItems = allItems.where((item) {
        // Handle category filtering
        bool matchesCategory = false;
        if (_selectedCategoryIndex == 0) {
          matchesCategory = true; // All categories
        } else {
          String selectedCategory = categories[_selectedCategoryIndex].toLowerCase();
          matchesCategory = item['name']!.toLowerCase().contains(selectedCategory);
        }

        // Handle search query
        bool matchesSearch = item['name']!.toLowerCase().contains(query);

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  // Filter items based on selected category
  void _filterByCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _applyFilters();
    });
  }

  // Navigate to product details page
  void _navigateToMilkProduct(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MilkProductPage(product: product),
      ),
    );
  }

  // Helper method to build image widget based on image path
  Widget _buildImage(Map<String, dynamic> item) {
    String imagePath = item['image'] ?? '';
    if (imagePath.startsWith('http')) {
      // If imagePath is a URL, use Image.network
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
      );
    } else {
      // Otherwise, assume it's an asset path
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text('Subscription Services'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeView()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to AddServiceProduct when clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddServiceProduct()),
              ).then((_) {
                // Refresh the product list after returning from AddServiceProduct
                setState(() {
                  // Reset allItems to predefinedItems
                  allItems = predefinedItems
                      .map((item) => Map<String, dynamic>.from(item))
                      .toList();
                });
                _fetchProducts();
              });
            },
          ),
        ],
      ),
      body: Column(
          children: [
      // Search Bar
      Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Find product",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    // Category Chips
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0),
    child: Container(
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
    ),
    ),
    SizedBox(height: 10),
    // Product Grid
    Expanded(
    child: displayedItems.isEmpty
    ? Center(child: Text('No products found'))
        : GridView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: displayedItems.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.7,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    ),
      itemBuilder: (context, index) {
        final item = displayedItems[index];
        return GestureDetector(
          onTap: () => _navigateToMilkProduct(item),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8)),
                    child: _buildImage(item),
                  ),
                ),
                // Product Details
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        item['priceWeekly'] ?? '',
                        style: TextStyle(color: Colors.blue),
                      ),
                      SizedBox(height: 2),
                      Text(
                        item['priceMonthly'] ?? '',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    ),
          ],
      ),
    );
  }
}


