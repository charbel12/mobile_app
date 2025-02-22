import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resapp/admin/admin_nav.dart';
import 'package:resapp/tools/colors.dart';
class AdminServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Services")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No services available."));
          }

          var services = snapshot.data!.docs;

          return ListView.separated(
            itemCount: services.length,
            separatorBuilder: (context, index) => Divider(thickness: 1.5, color: Colors.grey[300]),
            itemBuilder: (context, index) {
              var service = services[index];
              var serviceData = service.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Increased padding
                child: ListTile(
                  leading: serviceData['imageUrl'] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Rounded image corners
                    child: Image.network(serviceData['imageUrl'], width: 60, height: 60, fit: BoxFit.cover),
                  )
                      : Icon(Icons.image, size: 60),
                  title: Text(
                    serviceData['title'] ?? 'No Title',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailsPage(serviceData),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/add-service');
        },
        backgroundColor: AppColors.res_green, // Custom background color
        foregroundColor: Colors.white, // Icon color
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: AdminNav(currentIndex: 1),
    );
  }
}

class ServiceDetailsPage extends StatelessWidget {
  final Map<String, dynamic> serviceData;

  ServiceDetailsPage(this.serviceData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(serviceData['title'] ?? 'Service Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            serviceData['imageUrl'] != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12), // Rounded image corners
              child: Image.network(serviceData['imageUrl'], width: double.infinity, height: 200, fit: BoxFit.cover),
            )
                : Icon(Icons.image, size: 100),
            SizedBox(height: 16),
            Text(
              serviceData['title'] ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(serviceData['description'] ?? 'No description available'),
          ],
        ),
      ),
    );
  }
}
