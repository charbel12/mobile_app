import 'package:flutter/material.dart';
import 'package:resapp/tools/bottom_nav.dart';
import 'package:resapp/tools/property_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resapp/property/property_details_page.dart';
import 'package:resapp/tools/colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedListingType;
  String? _selectedPropertyType;
  bool _showFilters = false;

  final List<String> _listingTypes = ['SALE', 'RENT', 'EXCHANGE'];
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
  void initState() {
    super.initState();
    // _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: Column(
              children: [
                // Properties Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Properties',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/properties');
                              },
                              child: Text(
                                'View All',
                                style: TextStyle(color: AppColors.res_green),
                              ),
                            ),
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
                              return Center(
                                  child: Text('Error loading properties'));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                  child: Text('No properties available'));
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

                              final matchesListingType =
                                  _selectedListingType == null ||
                                      data['listingType']
                                          .toString()
                                          .toUpperCase()
                                          .contains(_selectedListingType!);

                              final matchesPropertyType =
                                  _selectedPropertyType == null ||
                                      data['propertyType']
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
                                    Icon(Icons.search_off,
                                        size: 48, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No properties match your search',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                final doc = filteredDocs[index];
                                final data = doc.data() as Map<String, dynamic>;

                                return Container(
                                  width: 280,
                                  margin: EdgeInsets.only(right: 16),
                                  child: PropertyCard(
                                    title: data['title'] ?? '',
                                    location: data['location'] ?? '',
                                    price: (data['price'] ?? 0).toDouble(),
                                    propertyType: data['propertyType'] ?? '',
                                    houseType: data['houseType'],
                                    listingType: data['listingType'] ?? '',
                                    images:
                                        List<String>.from(data['images'] ?? []),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PropertyDetailsPage(
                                            propertyId: doc.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Services Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Services',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/services');
                              },
                              child: Text(
                                'View All',
                                style: TextStyle(color: AppColors.res_green),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('services')
                              .where('status', isEqualTo: 'active')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error loading services'));
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                  child: Text('No services available'));
                            }

                            var services = snapshot.data!.docs;
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: services.length,
                              itemBuilder: (context, index) {
                                final service = services[index].data()
                                    as Map<String, dynamic>;
                                return Container(
                                  width: 280,
                                  margin: EdgeInsets.only(right: 16),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/service-details',
                                          arguments: services[index].id,
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                            child: Image.network(
                                              service['image'] ?? '',
                                              height: 150,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 150,
                                                  color: Colors.grey[200],
                                                  child:
                                                      Icon(Icons.error_outline),
                                                );
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  service['title'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  service['description'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      size: 16,
                                                      color: Colors.amber,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      '${(service['rating'] ?? 0.0).toStringAsFixed(1)}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      ' (${service['reviewCount'] ?? 0})',
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}
