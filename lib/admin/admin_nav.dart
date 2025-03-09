import 'package:flutter/material.dart';
import 'package:resapp/tools/colors.dart';

class AdminNav extends StatefulWidget {
  final int currentIndex;

  const AdminNav({Key? key, required this.currentIndex}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<AdminNav> {
  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddOptionsDialog();
    } else {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/admin/services');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/admin/profile');
          break;
      }
    }
  }

  void _showAddOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose an option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Add Property"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add-property');
                },
              ),
              ListTile(
                leading: Icon(Icons.sell),
                title: Text("Add Listing"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add-listing');
                },
              ),
              ListTile(
                leading: Icon(Icons.house),
                title: Text("Rent Property"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/rent-property');
                },
              ),
              ListTile(
                leading: Icon(Icons.swap_horiz),
                title: Text("Exchange Property"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/exchange-property');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.res_green,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sell),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.miscellaneous_services),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
