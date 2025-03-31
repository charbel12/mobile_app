import 'package:flutter/material.dart';
import 'package:resapp/tools/colors.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onItemTapped(int index) {
    if (index == widget.currentIndex) {
      return;
    }
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
          title: Text("Create New Listing"),
          content: Container(
            width: double.maxFinite,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildGridOption(Icons.sell, "Offer"),
                _buildGridOption(Icons.request_page, "Request"),
                _buildGridOption(Icons.construction, "Projects"),
                _buildGridOption(Icons.swap_horiz, "Exchange"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridOption(IconData icon, String text) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            '/listing-type',
            arguments: text, // Pass category as String
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.res_green),
            SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
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
          label: 'Properties',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, size: 32, color: AppColors.res_green),
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

class _DialogOption {
  final IconData icon;
  final String title;
  final String route;

  const _DialogOption({
    required this.icon,
    required this.title,
    required this.route,
  });
}
