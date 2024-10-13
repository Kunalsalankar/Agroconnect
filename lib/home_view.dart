import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure Firebase is set up
import 'transportation_services.dart';
import 'subscription.dart';
import 'auction.dart';
import 'ProductDetailPage.dart';
import 'ProfilePage.dart';
import 'AddToCartPage.dart';
import 'AboutUsPage.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs


class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Define the selected index for BottomNavigationBar
  int _selectedIndex = 0;

  // Sample product list with comprehensive details
  final List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'name': 'Soyabean',
      'price': 5000,
      'photo': 'assets/files/soyabean.jpg',
      'rating': 4.5,
      'location': 'Nashik',
      'quantity': '10 Quintal',
      'mobile_no': '9145393757',
      'farmer_name': 'Kunal Kishor Salanakar',
      'aadhar_number': '488109925903',
      'harvest_date': '26/10/2023',
      'video_url': 'https://www.example.com/soyabean_video',
    },
    {
      'id': 2,
      'name': 'Gram',
      'price': 3000,
      'photo': 'assets/files/gram.jpg',
      'rating': 4.2,
      'location': 'Ahmednagar',
      'quantity': '20 Quintal',
      'mobile_no': '9370482365',
      'farmer_name': 'Amit Sharma',
      'aadhar_number': '1234 5678 9012',
      'harvest_date': '15/09/2023',
      'video_url': 'https://www.example.com/gram_video',
    },
    {
      'id': 3,
      'name': 'Basmati Rice',
      'price': 2000,
      'photo': 'assets/files/rice.png',
      'rating': 4.5,
      'location': 'Nashik',
      'quantity': '13 Quintal',
      'mobile_no': '9730693440',
      'farmer_name': 'Rohit Deshmukh',
      'aadhar_number': '2345 6789 0123',
      'harvest_date': '10/08/2023',
      'video_url': 'https://www.example.com/rice_video',
    },
    {
      'id': 4,
      'name': 'Tur',
      'price': 9000,
      'photo': 'assets/files/tur.jpg',
      'rating': 4.5,
      'location': 'Nashik',
      'quantity': '14 Quintal',
      'mobile_no': '7666493440',
      'farmer_name': 'Suresh Patil',
      'aadhar_number': '3456 7890 1234',
      'harvest_date': '20/07/2023',
      'video_url': 'https://www.example.com/tur_video',
    },
    {
      'id': 5,
      'name': 'Cotton',
      'price': 1000,
      'photo': 'assets/files/cotton.jpg',
      'rating': 4.5,
      'location': 'Nashik',
      'quantity': '15 Quintal',
      'mobile_no': '7709593398',
      'farmer_name': 'Anita Kulkarni',
      'aadhar_number': '4567 8901 2345',
      'harvest_date': '05/06/2023',
      'video_url': 'https://www.example.com/cotton_video',
    },
    {
      'id': 6,
      'name': 'Wheat',
      'price': 2000,
      'photo': 'assets/files/wheat.jpg',
      'rating': 4.5,
      'location': 'Nashik',
      'quantity': '16 Quintal',
      'mobile_no': '7709562181',
      'farmer_name': 'Vikram Singh',
      'aadhar_number': '5678 9012 3456',
      'harvest_date': '18/05/2023',
      'video_url': 'https://www.example.com/wheat_video',
    },
    {
      'id': 7,
      'name': 'Maize',
      'price': 7000,
      'photo': 'assets/files/maize.jpg',
      'rating': 4.5,
      'location': 'Nashik',
      'quantity': '16 Quintal',
      'mobile_no': '7709562181',
      'farmer_name': 'Priya Joshi',
      'aadhar_number': '6789 0123 4567',
      'harvest_date': '30/04/2023',
      'video_url': 'https://www.example.com/maize_video',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agroconnect'),
        backgroundColor: Colors.green[600],
        actions: [],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildSearchBar(),
          ),
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

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeView()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AddToCartPage(product: products[_selectedIndex])));
        break;
      case 2:
        _launchMarketViewUrl();
        break;
    }
  }

  // Function to launch the URL for Market View
  void _launchMarketViewUrl() async {
    const url = 'https://agmarknet.gov.in/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          // Implement search functionality if required
        });
      },
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

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailPage(product: products[index]),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  products[index]['photo'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                products[index]['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: ₹${products[index]['price']} / Quintal'),
                  Text('Location: ${products[index]['location']}'),
                  Text('Quantity: ${products[index]['quantity']}'),
                  Row(
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < products[index]['rating']
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.green[800]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildDrawerHeader(),
            _buildMenuItem(Icons.person, 'Profile', ProfilePage()), // Added Profile Page
            _buildMenuItem(Icons.business, 'Subscription Services', SubscriptionPage()),
            _buildMenuItem(Icons.shopping_cart, 'Auction', AuctionPage()),
            _buildMenuItem(Icons.local_shipping, 'Transportation Services', TransportationServicesPage()),
            _buildMenuItem(Icons.info_outline, 'About Us', AboutUsPage()), // Added About Us
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 100, // Adjust the height to reduce the size of the green box
      decoration: BoxDecoration(
        color: Colors.green[600],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding for better alignment
        child: Align(
          alignment: Alignment.centerLeft, // Align text to the left
          child: Text(
            "Agroconnect",
            style: TextStyle(
              fontSize: 24.0, // Adjust font size as needed
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Widget? page, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (isLogout) {
          FirebaseAuth.instance.signOut().then((_) {
            Navigator.of(context).pushReplacementNamed('/login'); // Define route
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page!),
          );
        }
      },
    );
  }
}