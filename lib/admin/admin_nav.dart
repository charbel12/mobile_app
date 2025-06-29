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
    if(index ==  widget.currentIndex){
      return;
    }
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/admin/services');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/admin/contractor');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/admin/profile');
          break;
    }
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
          label: 'Contractors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
