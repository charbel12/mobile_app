import 'package:flutter/material.dart';

class ServiceRequestDetails extends StatelessWidget {
  final Map<String, dynamic> serviceData;
  ServiceRequestDetails({required this.serviceData});

  @override
  Widget build(BuildContext context) {
    print(serviceData);
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Request Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            serviceData['service_details'] != null &&
                serviceData['service_details']['img_path'] != null
                ? Image.network(
              serviceData['service_details']['img_path'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            )
                : Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child:
              Icon(Icons.image, size: 50, color: Colors.grey[600]),
            ),

            // Title & Status Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceData['service_details']['title'] ?? 'Unknown Service',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(serviceData['service_request']['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      serviceData['service_request']['status'] ?? 'Pending',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    serviceData['service_details']['description'] ?? 'No description available.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            _buildSectionTitle('User Information'),
            _buildInfoCard([
              _buildInfoRow('Name', serviceData['service_request']['user_name']),
              _buildInfoRow('Email', serviceData['service_request']['user_email']),
              _buildInfoRow('Phone', serviceData['service_request']['user_phone']),
            ]),

            if (serviceData['service_details']['questions'] != null &&
                serviceData['service_details']['questions'].isNotEmpty)
              _buildSectionTitle('Service Questions & Responses'),
            if (serviceData['service_details']['questions'] != null &&
                serviceData['service_details']['questions'].isNotEmpty)
              _buildInfoCard(
                List.generate(
                  serviceData['service_details']['questions'].length,
                      (index) {
                    String question = serviceData['service_details']['questions'][index];
                    String? response = serviceData['service_request']['responses'][question];
                    return _buildInfoRow(
                      question,
                      response ?? 'No response',
                    );
                  },
                ),
              ),

            // Created At
            _buildSectionTitle('Created At'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                serviceData['service_details']['createdAt']?.toDate().toString() ?? 'N/A',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper function to build section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper function to build an information row
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value ?? 'N/A', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }

  // Helper function to build an information card
  Widget _buildInfoCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: children),
        ),
      ),
    );
  }

  // Helper function to get status color
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
