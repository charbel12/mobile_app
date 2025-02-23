import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:resapp/admin/admin_nav.dart';
import 'package:resapp/tools/colors.dart';

class EditServicePage extends StatefulWidget {
  final String serviceId;
  final Map<String, dynamic> serviceData;

  EditServicePage({required this.serviceId, required this.serviceData});

  @override
  _EditServicePageState createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  File? _selectedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.serviceData['title']);
    _descriptionController =
        TextEditingController(text: widget.serviceData['description']);
    _existingImageUrl = widget.serviceData['imageUrl'];
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _updateService() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isNotEmpty && description.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(widget.serviceId)
          .update({
        'title': title,
        'description': description,
        'imageUrl':
            _selectedImage != null ? _selectedImage!.path : _existingImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Service updated successfully!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Service"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Service Title",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Enter title",
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.res_green, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text("Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: "Enter description",
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.res_green, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text("Image",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(_selectedImage!,
                    height: 100, width: 100, fit: BoxFit.cover)
                : _existingImageUrl != null
                    ? Image.network(_existingImageUrl!,
                        height: 100, width: 100, fit: BoxFit.cover)
                    : Icon(Icons.image, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo_library, color: Colors.grey),
              label:
                  Text("Select Image", style: TextStyle(color: Colors.green)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _updateService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.res_green,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(Icons.save, color: Colors.white),
                label: Text("Update Service",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminNav(currentIndex: 1),
    );
  }
}
