import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:resapp/tools/colors.dart';

class AddProperty extends StatefulWidget {
  @override
  _AddPropertyState createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<String> selectedUtilities = [];
  final List<XFile> images = [];

  final _formKey = GlobalKey<FormState>();

  void pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile> pickedImages = await _picker.pickMultiImage();
    setState(() {
      images.addAll(pickedImages);
    });
  }

  Future<void> saveData() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (selectedUtilities.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least 3 utilities')),
        );
        return;
      }
      if (images.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please upload at least 3 images')),
        );
        return;
      }

      List<String> imageUrls = [];
      for (var image in images) {
        final File file = File(image.path);
        final ref = FirebaseStorage.instance.ref().child(
            'property_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(file).then((taskSnapshot) async {
          String downloadUrl = await taskSnapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        });
      }
      FirebaseFirestore.instance.collection('properties').add({
        'title': titleController.text,
        'location': locationController.text,
        'area': areaController.text,
        'price': priceController.text,
        'description': descriptionController.text,
        'utilities': selectedUtilities,
        'images': imageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property listing saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Add Property Listing", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildLabel("Title"),
              buildTextField(titleController, "property title"),
              buildLabel("Location"),
              buildTextField(locationController, "location"),
              buildLabel("Area (sq ft)"),
              buildTextField(areaController, "area size"),
              buildLabel("Price"),
              buildTextField(priceController, "price", isNumber: true),
              buildLabel("Description"),
              buildTextField(descriptionController, "description"),
              SizedBox(height: 10),
              buildLabel("Utilities"),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  buildUtilityButton('Water'),
                  buildUtilityButton('Electricity'),
                  buildUtilityButton('Parking'),
                  buildUtilityButton('WiFi'),
                  buildUtilityButton('Great view'),
                  buildUtilityButton('Washing room'),
                  buildUtilityButton('Air conditioner'),
                ],
              ),
              SizedBox(height: 10),
              buildLabel("Upload Images"),
              GestureDetector(
                onTap: pickImages,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    images.isEmpty
                        ? "Upload your images"
                        : "${images.length} images selected",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.res_green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Create Listing',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper functions for consistent styling
  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        hintStyle:
            TextStyle(color: Color.fromARGB(97, 0, 0, 0)), // Light hint text
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey), // Default border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: AppColors.res_green,
              width: 2.0), // Green border when selected
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.grey), // Default border when not focused
        ),
        filled: true,
        fillColor: Colors.white, // Keeps input background white
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: Colors.black),
      validator: (value) => value?.isEmpty ?? true ? '$hint is required' : null,
    );
  }

  Widget buildUtilityButton(String label) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: Colors.black)),
      selected: selectedUtilities.contains(label),
      selectedColor: AppColors.res_green,
      backgroundColor: Colors.white,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            selectedUtilities.add(label);
          } else {
            selectedUtilities.remove(label);
          }
        });
      },
    );
  }
}
