import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:resapp/property/property_details_page.dart';
import 'package:resapp/tools/auth_service.dart';
import 'package:resapp/tools/bottom_nav.dart';
import 'package:resapp/tools/colors.dart';
import 'package:resapp/tools/property_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'service_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    _HandlePhoneNumber();
  }
  static Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await _firestore.collection('users').doc(user.uid).update(data);

      final prefs = await SharedPreferences.getInstance();

      if (data.containsKey('phone')) {
        await prefs.setString('phoneNumber', data['phone']);
      }
    } catch (e) {
      print('Error updating user data: $e');
      throw e;
    }
  }

  Future<void> _updateUserData() async {
    try {
      await updateUserData({
        'phone': _phone_controller.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
    }
  }

  final TextEditingController _phone_controller = TextEditingController();

  Future<void> _HandlePhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNum = prefs.getString('phoneNumber');
    if(phoneNum == null){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPopup();
      });
    }
  }
  void _showPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Please enter your phone number!"),
        content: TextField(
          controller: _phone_controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            labelText: "Phone Number",
            hintText: "Enter your phone number",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => {
              _updateUserData(),
              Navigator.of(context).pop()
              },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }


  final List<String> imgList = [
    'assets/slider/slider1.jpg',
    'assets/slider/slider2.jpg',
    'assets/slider/slider3.jpg',
    'assets/slider/slider4.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          _buildImageSlider(),
          _buildPropertySection(),
          _buildServiceSection(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildImageSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        aspectRatio: 16 / 9,
        enlargeCenterPage: true,
        viewportFraction: 1.0, // Make it full-width
        autoPlayInterval: Duration(seconds: 5),
      ),
      items: imgList.map((item) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          item,
          width: double.infinity, // Ensure full width
          fit: BoxFit.cover, // Adjust fit as needed
        ),
      )).toList(),
    );
  }

  Widget _buildPropertySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Featured Properties', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/properties'),
                child: Text('View All', style: TextStyle(color: AppColors.res_green)),
              ),
            ],
          ),
        ),
        Container(
          height: 270,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('properties')
                .where('status', isEqualTo: 'active')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return Container(
                    width: 300, // Slightly wider cards
                    margin: EdgeInsets.only(right: 16),
                    child: PropertyCard(
                      title: data['title'] ?? '',
                      location: data['location'] ?? '',
                      price: (data['price'] ?? 0).toDouble(),
                      propertyType: data['propertyType'] ?? '',
                      houseType: data['houseType'],
                      listingType: data['listingType'] ?? '',
                      images: List<String>.from(data['images'] ?? []),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailsPage(propertyId: doc.id),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Featured Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/services'),
                child: Text('View All', style: TextStyle(color: AppColors.res_green)),
              ),
            ],
          ),
        ),
        Container(
          height: 220,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('services')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final service = snapshot.data!.docs[index];
                  final data = service.data() as Map<String, dynamic>;
                  final imgPath = data['img_path'];

                  return Container(
                    width: 280,
                    margin: EdgeInsets.only(right: 16),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ServiceDetailsPage(service: service)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3, // More space for images
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                child: _buildServiceImage(imgPath),
                              ),
                            ),
                            Expanded(
                              flex: 2, // More space for text content
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data['title'] ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      data['description'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.star, size: 16, color: Colors.amber),
                                        SizedBox(width: 4),
                                        Text(
                                          '${(data['rating'] ?? 0.0).toStringAsFixed(1)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          ' (${data['reviewCount'] ?? 0})',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceImage(String? imgPath) {
    if (imgPath == null || imgPath.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(child: Icon(Icons.image_not_supported, color: Colors.grey[400])),
      );
    }

    if (imgPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imgPath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Center(child: Icon(Icons.error_outline, color: Colors.grey[400])),
        ),
      );
    }

    return Image.file(
      File(imgPath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: Center(child: Icon(Icons.error_outline, color: Colors.grey[400])),
      ),
    );
  }
}