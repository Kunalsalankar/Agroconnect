import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransportationServicesPage extends StatefulWidget {
  @override
  _TransportationServicesPageState createState() =>
      _TransportationServicesPageState();
}

class _TransportationServicesPageState
    extends State<TransportationServicesPage> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedType = 'All';

  // Existing driver list (pre-defined)
// Existing driver list (pre-defined)
  final List<Map<String, String>> predefinedDrivers = [
    {
      'name': 'Virat Sharma',
      'vehicle': 'Mini Truck',
      'license': 'ABC123',
      'photo': 'assets/files/riya.jpeg',
      'address': '123 Main St, Wardha',
      'rate': '20 Rs per Km',
      'mobile': '9145393757',
      'location': 'Wardha',
      'type': 'Mini Truck',
      'capacity': '2 tons'
    },
    {
      'name': 'Shubham Wagh',
      'vehicle': 'Truck',
      'license': 'XYZ456',
      'photo': 'assets/files/rutu.jpeg',
      'address': '456 Side St, Amravati',
      'rate': '25 Rs per Km',
      'mobile': '9145393757',
      'location': 'Amravati',
      'type': 'Truck',
      'capacity': '5 tons'
    },
    {
      'name': 'Rahul Sharma',
      'vehicle': 'Truck',
      'license': 'XYZ789',
      'photo': 'assets/files/download.jpeg',
      'address': '256 Side St, Pulgaon',
      'rate': '30 Rs per Km',
      'mobile': '7709562181',
      'location': 'Pulgaon',
      'type': 'Truck',
      'capacity': '6 tons'
    },
    {
      'name': 'Manoj Patil',
      'vehicle': 'Truck',
      'license': 'DEF123',
      'photo': 'assets/files/trunk.jpeg',
      'address': '789 North Rd, Nagpur',
      'rate': '22 Rs per Km',
      'mobile': '7709562181',
      'location': 'Nagpur',
      'type': 'Truck',
      'capacity': '7 tons'
    },
    {
      'name': 'Vijay More',
      'vehicle': 'Van',
      'license': 'LMN456',
      'photo': 'assets/files/trunk1.jpeg',
      'address': '654 East Blvd, Chandrapur',
      'rate': '28 Rs per Km',
      'mobile': '7709593398',
      'location': 'Chandrapur',
      'type': 'Van',
      'capacity': '1 ton'
    },
    {
      'name': 'Santosh Jadhav',
      'vehicle': 'Truck',
      'license': 'GHI789',
      'photo': 'assets/files/trunk3.jpeg',
      'address': '321 West Ave, Wardha',
      'rate': '18 Rs per Km',
      'mobile': '7709593398',
      'location': 'Wardha',
      'type': 'Truck',
      'capacity': '8 tons'
    },
  ];

  // List of third-party transportation services
  final List<Map<String, String>> thirdPartyServices = [
    {
      'name': 'TruckSuvidha',
      'url': 'https://www.trucksuvidha.com',
    },
    {
      'name': 'TRANSIN',
      'url': 'https://www.transin.in',
    },
    {
      'name': 'Shivneri Logistics',
      'url': 'https://www.shivnerilogistics.com',
    },

  ];

  // Function to fetch drivers from Firebase Firestore
  Stream<QuerySnapshot> _getFirebaseDrivers() {
    // Ensure the collection name matches your Firestore setup
    return FirebaseFirestore.instance.collection('driver').snapshots();
  }

  // Function to send WhatsApp message
  void _sendWhatsAppMessage(String phoneNumber) async {
    final Uri whatsappUrl = Uri.parse(
        "https://wa.me/$phoneNumber?text=Hello, I am interested in your transportation services.");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  // Function to make a phone call
  void _makePhoneCall(String phoneNumber) async {
    final Uri telUrl = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not initiate call')),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Helper function to build driver cards
  Widget _buildDriverCard(Map<String, String> driver) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(driver['photo']!),
        ),
        title: Text(driver['name']!),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle: ${driver['vehicle']}'),
            Text('Rate: ${driver['rate']}'),
            Text('Location: ${driver['location']}'),
            Text('Capacity: ${driver['capacity']}'), // Corrected key
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.phone),
              onPressed: () => _makePhoneCall(driver['mobile']!),
            ),
            IconButton(
              icon: Icon(Icons.message),
              onPressed: () => _sendWhatsAppMessage(driver['mobile']!),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build Firestore driver cards
  Widget _buildFirestoreDriverCard(Map<String, dynamic> driverData) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: driverData['imagePath'] != null
              ? NetworkImage(driverData['imagePath'])
              : null,
          child: driverData['imagePath'] == null
              ? Icon(Icons.person)
              : null,
        ),
        title: Text(driverData['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle: ${driverData['vehicle']}'),
            Text('Rate: ${driverData['rate']} Rs per Km'),
            Text('Location: ${driverData['address']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.phone),
              onPressed: () => _makePhoneCall(driverData['mobile']),
            ),
            IconButton(
              icon: Icon(Icons.message),
              onPressed: () => _sendWhatsAppMessage(driverData['mobile']),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build third-party service cards
  Widget _buildThirdPartyServiceCard(Map<String, String> service) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.local_shipping, color: Colors.blue),
        title: Text(service['name']!),
        trailing: IconButton(
          icon: Icon(Icons.open_in_browser, color: Colors.green),
          onPressed: () async {
            final Uri url = Uri.parse(service['url']!);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch ${service['url']}')),
              );
            }
          },
        ),
        onTap: () async {
          final Uri url = Uri.parse(service['url']!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch ${service['url']}')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Transportation Services'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to Driver Registration
              Navigator.pushNamed(context, '/driver');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filter Section
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Name or Location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 16),
            // All Drivers Section
            Text(
              'All Drivers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Predefined Drivers List
            Text(
              'Predefined Drivers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: predefinedDrivers.length,
              itemBuilder: (context, index) {
                final driver = predefinedDrivers[index];
                if (selectedType != 'All' &&
                    driver['vehicle'] != selectedType) {
                  return SizedBox.shrink(); // Hide if filter does not match
                }
                if (searchQuery.isNotEmpty &&
                    !driver['name']!
                        .toLowerCase()
                        .contains(searchQuery) &&
                    !driver['location']!
                        .toLowerCase()
                        .contains(searchQuery)) {
                  return SizedBox.shrink(); // Hide if search does not match
                }
                return _buildDriverCard(driver);
              },
            ),
            SizedBox(height: 16),

            // Registered Drivers from Firestore
            Text(
              'Registered Drivers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: _getFirebaseDrivers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final driverDocs = snapshot.data!.docs;
                if (driverDocs.isEmpty) {
                  return Text('No drivers registered yet.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: driverDocs.length,
                  itemBuilder: (context, index) {
                    final driverData =
                    driverDocs[index].data() as Map<String, dynamic>;
                    if (selectedType != 'All' &&
                        driverData['vehicle'] != selectedType) {
                      return SizedBox.shrink(); // Hide if filter does not match
                    }
                    if (searchQuery.isNotEmpty &&
                        !driverData['name']!
                            .toLowerCase()
                            .contains(searchQuery) &&
                        !driverData['address']!
                            .toLowerCase()
                            .contains(searchQuery)) {
                      return SizedBox.shrink(); // Hide if search does not match
                    }

                    return _buildFirestoreDriverCard(driverData);
                  },
                );
              },
            ),
            SizedBox(height: 24),

            // Third-Party Logistics Services Section
            Text(
              'Third-Party Logistics Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: thirdPartyServices.length,
              itemBuilder: (context, index) {
                final service = thirdPartyServices[index];
                return _buildThirdPartyServiceCard(service);
              },
            ),
          ],
        ),
      ),
    );
  }
}
