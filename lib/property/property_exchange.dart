import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:resapp/tools/property_form.dart';
import 'package:resapp/tools/loading_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class PropertyExchangePage extends StatefulWidget {
  @override
  _PropertyExchangePageState createState() => _PropertyExchangePageState();
}

class _PropertyExchangePageState extends State<PropertyExchangePage> {
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _handleSubmit(PropertyFormData formData) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Upload images first
      List<String> imageUrls = [];
      for (File image in formData.images) {
        String fileName = path.basename(image.path);
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String storagePath = 'properties/$userId/$timestamp\_$fileName';

        final storageRef = FirebaseStorage.instance.ref().child(storagePath);
        await storageRef.putFile(image);
        String downloadUrl = await storageRef.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // Create the property listing
      await FirebaseFirestore.instance.collection('properties').add({
        'userId': userId,
        'title': formData.title,
        'description': formData.description,
        'location': formData.location,
        'price': formData.price,
        'propertyType': formData.propertyType.toString(),
        'listingType': ListingType.exchange.toString(),
        'features': formData.features,
        'images': imageUrls,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'exchangePreferences':
            formData.additionalDetails['exchangePreferences'] ?? '',
        'preferredLocations':
            formData.additionalDetails['preferredLocations'] ?? [],
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Property listed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to list property: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List Property for Exchange",
            style: TextStyle(color: Colors.black)),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: LoadingState(
        isLoading: _isLoading,
        loadingText: 'Creating your listing...',
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              PropertyForm(
                initialData: PropertyFormData(
                  listingType: ListingType.exchange,
                  additionalDetails: {
                    'exchangePreferences': '',
                    'preferredLocations': [],
                  },
                ),
                allowedPropertyTypes: [
                  PropertyType.house,
                  PropertyType.apartment,
                  PropertyType.office,
                  PropertyType.shop,
                  PropertyType.warehouse,
                ],
                allowedListingTypes: [ListingType.exchange],
                onSubmit: _handleSubmit,
                submitButtonText: 'List Property for Exchange',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
