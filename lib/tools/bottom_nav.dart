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
          title: Text(
            "What would you like to list?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionGroup(
                "Property",
                [
                  _DialogOption(
                    icon: Icons.sell,
                    title: "List for Sale",
                    route: '/property-sale',
                  ),
                  _DialogOption(
                    icon: Icons.home,
                    title: "List for Rent",
                    route: '/property-rent',
                  ),
                  _DialogOption(
                    icon: Icons.swap_horiz,
                    title: "List for Exchange",
                    route: '/property-exchange',
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildOptionGroup(
                "Land",
                [
                  _DialogOption(
                    icon: Icons.landscape,
                    title: "List for Sale",
                    route: '/land-sale',
                  ),
                  _DialogOption(
                    icon: Icons.terrain,
                    title: "List for Rent",
                    route: '/land-rent',
                  ),
                ],
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  Widget _buildOptionGroup(String title, List<_DialogOption> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        ...options.map((option) => ListTile(
              leading: Icon(option.icon, color: AppColors.res_green),
              title: Text(option.title),
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, option.route);
              },
            )),
      ],
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
