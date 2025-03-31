import 'package:flutter/material.dart';
import 'package:resapp/tools/bottom_nav.dart';
import 'package:resapp/tools/property_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resapp/property/property_details_page.dart';
import 'package:resapp/tools/colors.dart';

class PropertiesPage extends StatefulWidget {
  @override
  _PropertiesPageState createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedListingType;
  String? _selectedPropertyType;
  bool _showFilters = false;

  final List<String> _listingTypes = ['OFFER', 'REQUEST', 'EXCHANGE', 'PROJECTS'];
  final List<String> _propertyTypes = [
    'HOUSE',
    'APARTMENT',
    'LAND',
    'OFFICE',
    'SHOP',
    'WAREHOUSE'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedListingType = null;
      _selectedPropertyType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Properties", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by location or title..',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            ),
                          IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color: _showFilters
                                  ? AppColors.res_green
                                  : Colors.grey,
                            ),
                            onPressed: _toggleFilters,
                          ),
                        ],
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                // Filters
                if (_showFilters) ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Listing Type',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _listingTypes.map((type) {
                                  final isSelected =
                                      _selectedListingType == type;
                                  return Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(type),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedListingType =
                                              selected ? type : null;
                                        });
                                      },
                                      selectedColor:
                                          AppColors.res_green.withOpacity(0.2),
                                      checkmarkColor: AppColors.res_green,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Property Type',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _propertyTypes.map((type) {
                                  final isSelected =
                                      _selectedPropertyType == type;
                                  return Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(type),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedPropertyType =
                                              selected ? type : null;
                                        });
                                      },
                                      selectedColor:
                                          AppColors.res_green.withOpacity(0.2),
                                      checkmarkColor: AppColors.res_green,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (_selectedListingType != null ||
                      _selectedPropertyType != null)
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text('Clear Filters'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.res_green,
                      ),
                    ),
                ],
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('properties')
                  .where('status', isEqualTo: 'active')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(
                    child: Text('Error loading properties'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No properties available'),
                  );
                }

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final matchesSearch = _searchQuery.isEmpty ||
                      data['location']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      data['title']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());

                  final matchesListingType = _selectedListingType == null ||
                      data['listingType']
                          .toString()
                          .toUpperCase()
                          .contains(_selectedListingType!);

                  final matchesPropertyType = _selectedPropertyType == null ||
                      data['houseType']
                          .toString()
                          .toUpperCase()
                          .contains(_selectedPropertyType!);

                  return matchesSearch &&
                      matchesListingType &&
                      matchesPropertyType;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No properties match your search',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return PropertyCard(
                        title: data['title'] ?? '',
                        location: data['location'] ?? '',
                        price: (data['price'] ?? 0).toDouble(),
                        propertyType: data['propertyType'] ?? '',
                        houseType: data['houseType'],
                        listingType: data['listingType'] ?? '',
                        images: List<String>.from(data['images'] ?? []),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertyDetailsPage(
                                propertyId: doc.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }
}
