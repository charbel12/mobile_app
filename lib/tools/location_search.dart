import 'package:flutter/material.dart';
import 'package:resapp/tools/colors.dart';

class LocationSearchField extends StatefulWidget {
  final Function(String) onLocationSelected;
  final String? initialValue;

  const LocationSearchField({
    Key? key,
    required this.onLocationSelected,
    this.initialValue,
  }) : super(key: key);

  @override
  _LocationSearchFieldState createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;
  String _searchText = '';

  // Add your locations here
  final List<String> _locations = [
    'West Beqaa',
    'Hermel',
    'Baalbeq',
    'Zahle',
    'Jezzine',
    'Sour',
    'Saida',
    'Batroun',
    'Koura',
    'Donnieh',
    'Bcharre',
    'Zgharta',
    'Tripoli',
    'Akkar',
    'Nabatieh',
    'Bint-Jbeil',
    'Hasbaia',
    'Marjeyoun',
    'Beirut',
    'Maten',
    'Baabda',
    'Jbeil',
    'Aaley',
    'Kesrwan',
  ];

  List<String> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _filteredLocations = _locations;

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showDropdown = true;
        });
      }
    });
  }

  void _filterLocations(String query) {
    setState(() {
      _searchText = query;
      if (query.isEmpty) {
        _filteredLocations = _locations;
      } else {
        _filteredLocations = _locations
            .where((location) =>
                location.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Location',
            hintText: 'Search for a location',
            prefixIcon: Icon(Icons.location_on),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _filterLocations('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: _filterLocations,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a location';
            }
            if (!_locations.contains(value)) {
              return 'Please select a valid location from the list';
            }
            return null;
          },
        ),
        if (_showDropdown && _focusNode.hasFocus)
          Container(
            margin: EdgeInsets.only(top: 4),
            padding: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxHeight: 200,
            ),
            child: _filteredLocations.isEmpty
                ? ListTile(
                    title: Text(
                      'No locations found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];
                      return ListTile(
                        title: Text(location),
                        onTap: () {
                          _controller.text = location;
                          widget.onLocationSelected(location);
                          setState(() {
                            _showDropdown = false;
                          });
                          _focusNode.unfocus();
                        },
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
