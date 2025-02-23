import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resapp/admin/admin_nav.dart';
import 'package:resapp/tools/colors.dart';
import 'package:resapp/admin/edit-service.dart';

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
            separatorBuilder: (context, index) =>
                Divider(thickness: 1.5, color: Colors.grey[300]),
            itemBuilder: (context, index) {
              var service = services[index];
              var serviceData = service.data() as Map<String, dynamic>;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: ListTile(
                  leading: serviceData['imageUrl'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(serviceData['imageUrl'],
                              width: 60, height: 60, fit: BoxFit.cover),
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
                        builder: (context) => ServiceDetailsPage(
                          serviceId: service.id,
                          serviceData: serviceData,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showDeleteDialog(context, service.id);
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
        backgroundColor: AppColors.res_green,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: AdminNav(currentIndex: 1),
    );
  }

  void _showDeleteDialog(BuildContext context, String serviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Service"),
        content: Text("Are you sure you want to delete this service?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('services')
                  .doc(serviceId)
                  .delete();
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ServiceDetailsPage extends StatelessWidget {
  final Map<String, dynamic> serviceData;
  final String serviceId;

  ServiceDetailsPage({required this.serviceId, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceData['title'] ?? 'Service Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditServicePage(
                      serviceId: serviceId, serviceData: serviceData),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            serviceData['imageUrl'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      serviceData['imageUrl'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
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
