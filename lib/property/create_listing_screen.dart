import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../tools/location_search.dart';

class CreateListingScreen extends StatefulWidget {
  final String listingType;

  const CreateListingScreen({Key? key, required this.listingType}) : super(key: key);

  @override
  _CreateListingScreenState createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  late final TextEditingController _locationController = TextEditingController();

  String? _propertyType;
  String? _houseType;
  bool _isSaving = false;
  List<File> _selectedImages = [];
  List<String> _selectedFeatures = [];

  final List<String> _houseTypes = ['Office', 'Apartment', 'Duplex', 'Villa', 'House', 'Other'];
  final List<String> _availableFeatures = [
    'Parking', 'Pool', 'Garden', 'Security', 'Furnished',
    'Balcony', 'Elevator', 'WiFi', 'AC', 'Heating'
  ];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Widget _buildFeatureChip(String feature) {
    return ChoiceChip(
      label: Text(feature),
      selected: _selectedFeatures.contains(feature),
      onSelected: (selected) => setState(() {
        selected ? _selectedFeatures.add(feature) : _selectedFeatures.remove(feature);
      }),
      selectedColor: Colors.green,
      labelStyle: TextStyle(
        color: _selectedFeatures.contains(feature) ? Colors.white : Colors.black,
      ),
    );
  }


  Widget _buildImagePreview() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return GestureDetector(
            onTap: _pickImages,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: const Icon(Icons.add_photo_alternate, size: 40),
            ),
          );
        }

        final imageIndex = index - 1;
        return Stack(
          children: [
            Image.file(
              _selectedImages[imageIndex],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => setState(() => _selectedImages.removeAt(imageIndex)),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<List<String>> _uploadImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final storage = FirebaseStorage.instance;
    List<String> imageUrls = [];

    for (var imageFile in _selectedImages) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = storage.ref().child('listings/${user.uid}/$timestamp.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one image')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final imageUrls = await _uploadImages();

      await FirebaseFirestore.instance.collection('properties').add({
        'listingType': widget.listingType,
        'propertyType': _propertyType,
        'houseType': _propertyType == 'Property' ? _houseType : null,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'location': _locationController.text,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'features': _selectedFeatures,
        'images': imageUrls,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Listing'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _propertyType,
                decoration: const InputDecoration(
                  labelText: 'Property Type*',
                  border: OutlineInputBorder(),
                ),
                items: ['Land', 'Property'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _propertyType = value;
                  _houseType = null;
                }),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              if (_propertyType == 'Property')
                DropdownButtonFormField<String>(
                  value: _houseType,
                  decoration: const InputDecoration(
                    labelText: 'House Type*',
                    border: OutlineInputBorder(),
                  ),
                  items: _houseTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _houseType = value),
                  validator: (value) => _propertyType == 'Property' && value == null
                      ? 'Required'
                      : null,
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price*',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              LocationSearchField(
                onLocationSelected: (location) {
                  _locationController.text = location;
                },
                initialValue: _locationController.text,
              ),
              const SizedBox(height: 20),
              const Text('Photos*', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              _buildImagePreview(),
              const SizedBox(height: 20),
              const Text('Features', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableFeatures.map(_buildFeatureChip).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: _isSaving
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('PUBLISH LISTING',
                      style: TextStyle(fontSize: 16, color: Colors.green)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}