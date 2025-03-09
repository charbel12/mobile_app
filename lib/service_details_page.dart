import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:resapp/services_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resapp/tools/loading_state.dart';
import 'package:resapp/tools/validators.dart';
import 'package:resapp/tools/colors.dart';
import 'package:resapp/tools/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class ServiceDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot service;

  const ServiceDetailsPage({required this.service});

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isOffline = false;
  final ConnectivityService _connectivityService = ConnectivityService();
  Map<String, dynamic>? _serviceData;

  @override
  void initState() {
    super.initState();
    _loadServiceData();
    _setupConnectivityListener();
    _checkInitialConnectivity();
  }

  void _loadServiceData() {
    try {
      _serviceData = widget.service.data() as Map<String, dynamic>;
      List<dynamic> questions = _serviceData?['questions'] ?? [];
      for (var question in questions) {
        _controllers[question.toString()] = TextEditingController();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading service details. Please try again.';
        });
      }
    }
  }

  Future<void> _checkInitialConnectivity() async {
    bool isOnline = await _connectivityService.isOnline();
    setState(() {
      _isOffline = !isOnline;
    });
  }

  void _setupConnectivityListener() {
    _connectivityService.connectivityStream.listen((result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() async {
    if (_isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Cannot submit while offline. Please check your connection.")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final userEmail = prefs.getString('userEmail') ?? '';
      final userName = prefs.getString('fullName') ?? '';
      final userPhone = prefs.getString('phoneNumber') ?? '1';

      await FirebaseFirestore.instance.collection('service_requests').add({
        'service_id': widget.service.id,
        'title': _serviceData!['title'],
        'responses': _controllers
            .map((key, controller) => MapEntry(key, controller.text)),
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': userId,
        'user_email': userEmail,
        'user_name': userName,
        'user_phone': userPhone,
        'status': 'pending',
      });

      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Your service request has been submitted successfully!"),
          backgroundColor: AppColors.res_green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to submit request. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_serviceData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Service Details'),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error loading service details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _loadServiceData();
                      setState(() {});
                    }
                  });
                },
                child: Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.res_green,
                ),
              ),
            ],
          ),
        ),
      );
    }

    List questions = _serviceData!['questions'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _serviceData!['title'] ?? 'Service Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: LoadingState(
        isLoading: _isLoading,
        loadingText: 'Submitting your request...',
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_serviceData!['img_path'] != null &&
                      _serviceData!['img_path'].toString().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildServiceImage(_serviceData!['img_path']),
                    )
                  else
                    _buildNoImagePlaceholder(),
                  SizedBox(height: 24),
                  Text(
                    _serviceData!['description'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Service Request Form',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_isOffline)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.wifi_off, color: Colors.orange[800]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You are currently offline. Please check your connection to submit the form.',
                              style: TextStyle(color: Colors.orange[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ...questions.map((question) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          controller: _controllers[question],
                          decoration: InputDecoration(
                            labelText: question,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.res_green, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) =>
                              Validators.validateRequired(value, question),
                          maxLines:
                              question.toLowerCase().contains('description')
                                  ? 3
                                  : 1,
                        ),
                      )),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isOffline ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.res_green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Submit Request",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImage(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      );
    } else {
      return Image.file(
        File(imagePath),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.res_green),
            ),
            SizedBox(height: 8),
            Text(
              'Loading image...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text(
            'Error loading image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text(
            'No image available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text("Services", style: TextStyle(fontWeight: FontWeight.bold))),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No services available"));
          }

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var service = snapshot.data!.docs[index];
                return ServiceCard(
                  title: service['title'],
                  imgPath: service['img_path'],
                  description: service['description'],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ServiceDetailsPage(service: service),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
