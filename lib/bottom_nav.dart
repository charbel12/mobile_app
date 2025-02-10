import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddOptionsDialog();
    } else {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/properties');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/services');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
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
      selectedItemColor: const Color.fromARGB(255, 94, 202, 98),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sell),
          label: 'Properties',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, size: 32, color: Color.fromARGB(255, 94, 202, 98)),
          label: 'New',
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
