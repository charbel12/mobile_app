import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:resapp/tools/property_form.dart';
import 'package:resapp/tools/loading_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class LandSalePage extends StatefulWidget {
  @override
  _LandSalePageState createState() => _LandSalePageState();
}

class _LandSalePageState extends State<LandSalePage> {
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
        'propertyType': PropertyType.land.toString(),
        'listingType': ListingType.sale.toString(),
        'features': formData.features,
        'images': imageUrls,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'landSize': formData.additionalDetails['landSize'] ?? '',
        'landType': formData.additionalDetails['landType'] ?? '',
        'documents': formData.additionalDetails['documents'] ?? [],
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Land listed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to list land: ${e.toString()}';
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
        title:
            Text("List Land for Sale", style: TextStyle(color: Colors.black)),
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
                  propertyType: PropertyType.land,
                  listingType: ListingType.sale,
                  additionalDetails: {
                    'landSize': '',
                    'landType': '',
                    'documents': [],
                  },
                ),
                allowedPropertyTypes: [PropertyType.land],
                allowedListingTypes: [ListingType.sale],
                onSubmit: _handleSubmit,
                submitButtonText: 'List Land for Sale',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
