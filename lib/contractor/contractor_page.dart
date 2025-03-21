import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resapp/tools/property_card.dart';
import 'package:resapp/property/property_details_page.dart';
import 'package:resapp/tools/colors.dart';
import 'package:resapp/contractor/contractor_nav.dart';

class ContractorPage extends StatefulWidget {
  @override
  _ContractorPageState createState() => _ContractorPageState();
}

class _ContractorPageState extends State<ContractorPage> {
  Future<void> _deleteProperty(String propertyId) async {
    try {
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Property deleted successfully'),
          backgroundColor: AppColors.res_green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete property: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  void _deleteService(String serviceId) {
    FirebaseFirestore.instance.collection('services_request').doc(serviceId).delete();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Admin Dashboard',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
              labelColor: AppColors.res_green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.res_green,
              tabs: [
                Tab(text: 'Properties'),
                Tab(text: 'Services'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildPropertiesTab(),
              _buildServicesTab(),
            ],
          ),
          bottomNavigationBar: ContractorNav(currentIndex: 0)
      ),
    );
  }

  Widget _buildServicesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_requests')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading services'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No services available'),
          );
        }

        return Padding(
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(data['title'] ?? 'Unknown Service'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${data['status'] ?? 'N/A'}'),
                      Text('User: ${data['user_name'] ?? 'N/A'}'),
                      Text('Email: ${data['user_email'] ?? 'N/A'}'),
                      Text('Phone: ${data['user_phone'] ?? 'N/A'}'),
                      Text('Requested at: ${data['timestamp']?.toDate().toString() ?? 'N/A'}'),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }


  Widget _buildPropertiesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('properties')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading properties'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No properties available'),
          );
        }

        return Padding(
          padding: EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Stack(
                children: [
                  PropertyCard(
                    title: data['title'] ?? '',
                    location: data['location'] ?? '',
                    price: (data['price'] ?? 0).toDouble(),
                    propertyType: data['propertyType'] ?? '',
                    houseType: data['houseType'],
                    listingType: data['listingType'] ?? '',
                    images: List<String>.from(data['images'] ?? []),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailsPage(
                            propertyId: doc.id,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
