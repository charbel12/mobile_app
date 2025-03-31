// unified_property_form.dart
import 'package:flutter/material.dart';
import 'package:resapp/tools/property_form.dart';

class UnifiedPropertyForm extends StatelessWidget {
  final String category;
  final String listingType;

  const UnifiedPropertyForm({
    Key? key,
    required this.category,
    required this.listingType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Listinssg")),
      body: PropertyForm(
        initialData: PropertyFormData(
          propertyType: listingType == 'land'
              ? PropertyType.land
              : PropertyType.house,
          listingType: _getListingType(category),
          additionalDetails: _getAdditionalDetails(),
        ),
        allowedPropertyTypes: _getAllowedPropertyTypes(),
        allowedListingTypes: _getAllowedListingTypes(),
        onSubmit: (data) => _handleSubmit(data, context),
        submitButtonText: 'Submit Listing',
      ),
    );
  }

  List<PropertyType> _getAllowedPropertyTypes() {
    return listingType == 'land'
        ? [PropertyType.land]
        : [
      PropertyType.house,
      PropertyType.apartment,
      PropertyType.office,
      PropertyType.shop,
      PropertyType.warehouse,
    ];
  }

  List<ListingType> _getAllowedListingTypes() {
    switch (category) {
      case 'offer':
        return [ListingType.sale, ListingType.rent];
      case 'request':
        return [ListingType.rent];
      case 'exchange':
        return [ListingType.exchange];
      default:
        return ListingType.values;
    }
  }

  ListingType _getListingType(String category) {
    switch (category) {
      case 'offer': return ListingType.sale;
      case 'request': return ListingType.rent;
      case 'exchange': return ListingType.exchange;
      default: return ListingType.sale;
    }
  }

  Map<String, dynamic> _getAdditionalDetails() {
    if (listingType == 'land') {
      return {
        'landSize': '',
        'landType': '',
        'documents': [],
        if (category == 'rent') 'rentalPeriod': '',
      };
    }
    return {};
  }

  void _handleSubmit(PropertyFormData data, BuildContext context) {
    // Handle form submission logic here
    // You can merge the submission logic from existing forms
    Navigator.pop(context);
  }
}