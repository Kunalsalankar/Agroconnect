import 'package:flutter/material.dart';
import 'milkproductpage.dart';
import 'home_view.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final List<Map<String, String>> allItems = [
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
      'image': 'assets/files/milk 2.jpeg',
      'priceWeekly': '400Rs Weekly',
      'priceMonthly': '2400Rs Monthly',
      'mobile_no': '7776884378',
      'farmer_name': 'Virat Sharma',
      'aadhar_number': '1234-2345-1230',
    },
  ];

  List<Map<String, String>> displayedItems = [];
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  final List<String> categories = ['All', 'Milk', 'Cheese', 'Butter'];

  @override
  void initState() {
    super.initState();
    displayedItems = allItems;
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      displayedItems = allItems.where((item) {
        bool matchesCategory = _selectedCategoryIndex == 0 ||
            item['name']!.toLowerCase().contains(categories[_selectedCategoryIndex].toLowerCase());
        bool matchesSearch = item['name']!.toLowerCase().contains(query);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _filterByCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _applyFilters();
    });
  }

  void _navigateToMilkProduct(Map<String, String> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MilkProductPage(product: product),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text('Subscription Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeView()),
            );
          },
        ),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: GridView.builder(
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
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                            child: Image.asset(
                              item['image']!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                item['priceWeekly']!,
                                style: TextStyle(color: Colors.blue),
                              ),
                              SizedBox(height: 2),
                              Text(
                                item['priceMonthly']!,
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
