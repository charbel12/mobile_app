import 'package:flutter/material.dart';
import 'package:resapp/tools/location_search.dart';
import 'package:resapp/tools/colors.dart';
import 'package:resapp/tools/validators.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

enum PropertyType { house, apartment, land, office, shop, warehouse }

enum ListingType { sale, rent, exchange }

enum HouseType { villa, apartment, duplex, triplex, studio, townhouse }

class PropertyFormData {
  String title;
  String description;
  String location;
  double price;
  PropertyType propertyType;
  ListingType listingType;
  HouseType? houseType;
  List<String> features;
  List<File> images;
  Map<String, dynamic> additionalDetails;

  static const List<String> availableFeatures = [
    'Air Conditioning',
    'Parking',
    'Swimming Pool',
    'Security System',
    'Garden',
    'Balcony',
    'Elevator',
    'Furnished',
    'Gym',
    'Storage Room',
    'High Speed Internet',
    'Backup Generator',
    'Water Tank',
    'Solar System',
    'Near Schools',
    'Near Shopping Centers',
    'Near Public Transport',
    'Sea View',
    'Mountain View',
    'City View',
  ];

  PropertyFormData({
    this.title = '',
    this.description = '',
    this.location = '',
    this.price = 0.0,
    this.propertyType = PropertyType.house,
    this.listingType = ListingType.sale,
    this.houseType,
    List<String>? features,
    List<File>? images,
    Map<String, dynamic>? additionalDetails,
  })  : this.features = features ?? [],
        this.images = images ?? [],
        this.additionalDetails = additionalDetails ?? {};
}

class PropertyForm extends StatefulWidget {
  final PropertyFormData initialData;
  final List<PropertyType> allowedPropertyTypes;
  final List<ListingType> allowedListingTypes;
  final Function(PropertyFormData) onSubmit;
  final String submitButtonText;

  const PropertyForm({
    Key? key,
    required this.initialData,
    required this.allowedPropertyTypes,
    required this.allowedListingTypes,
    required this.onSubmit,
    this.submitButtonText = 'Submit Listing',
  }) : super(key: key);

  @override
  _PropertyFormState createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  final _formKey = GlobalKey<FormState>();
  late PropertyFormData _formData;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _featureController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _formData = widget.initialData;
    _titleController.text = _formData.title;
    _descriptionController.text = _formData.description;
    _priceController.text = _formData.price.toString();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _formData.images.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _formData.images.removeAt(index);
    });
  }

  void _addFeature() {
    if (_featureController.text.isNotEmpty) {
      setState(() {
        if (_formData.features is List<String>) {
          _formData.features.add(_featureController.text);
          _featureController.clear();
        }
      });
    }
  }

  void _removeFeature(int index) {
    setState(() {
      if (_formData.features is List<String>) {
        _formData.features.removeAt(index);
      }
    });
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PropertyFormData.availableFeatures.map((feature) {
            final isSelected = _formData.features.contains(feature);
            return FilterChip(
              label: Text(feature),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _formData.features.add(feature);
                  } else {
                    _formData.features.remove(feature);
                  }
                });
              },
              selectedColor: AppColors.res_green.withOpacity(0.2),
              checkmarkColor: AppColors.res_green,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) => Validators.validateRequired(value, 'Title'),
            onChanged: (value) => _formData.title = value,
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<PropertyType>(
            value: _formData.propertyType,
            decoration: InputDecoration(
              labelText: 'Property Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: widget.allowedPropertyTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.toString().split('.').last.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _formData.propertyType = value;
                  // Reset house type if property type is not house
                  if (value != PropertyType.house) {
                    _formData.houseType = null;
                  }
                });
              }
            },
          ),
          SizedBox(height: 16),
          if (_formData.propertyType == PropertyType.house)
            Column(
              children: [
                DropdownButtonFormField<HouseType>(
                  value: _formData.houseType ?? HouseType.villa,
                  decoration: InputDecoration(
                    labelText: 'House Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: HouseType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child:
                          Text(type.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _formData.houseType = value);
                    }
                  },
                  validator: (value) =>
                      _formData.propertyType == PropertyType.house &&
                              value == null
                          ? 'Please select a house type'
                          : null,
                ),
                SizedBox(height: 16),
              ],
            ),
          SizedBox(height: 16),
          DropdownButtonFormField<ListingType>(
            value: _formData.listingType,
            decoration: InputDecoration(
              labelText: 'Listing Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: widget.allowedListingTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.toString().split('.').last.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _formData.listingType = value);
              }
            },
          ),
          SizedBox(height: 16),
          LocationSearchField(
            initialValue: _formData.location,
            onLocationSelected: (location) => _formData.location = location,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Price (USD)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => Validators.validateNumber(value, 'Price'),
            onChanged: (value) => _formData.price = double.tryParse(value) ?? 0,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 3,
            validator: (value) =>
                Validators.validateRequired(value, 'Description'),
            onChanged: (value) => _formData.description = value,
          ),
          SizedBox(height: 16),
          _buildFeaturesSection(),
          SizedBox(height: 16),
          Text(
            'Images',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: Icon(Icons.add_photo_alternate),
            label: Text('Add Images'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.res_green,
            ),
          ),
          if (_formData.images.isNotEmpty)
            Container(
              height: 120,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _formData.images.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_formData.images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit(_formData);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.res_green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                widget.submitButtonText,
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
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _featureController.dispose();
    super.dispose();
  }
}
