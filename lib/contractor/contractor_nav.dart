import 'package:flutter/material.dart';
import 'package:resapp/tools/colors.dart';

class ContractorNav extends StatefulWidget {
  final int currentIndex;

  const ContractorNav({Key? key, required this.currentIndex}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<ContractorNav> {
  void _onItemTapped(int index) {
    if(index ==  widget.currentIndex){
      return;
    }
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/contractor');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/contractor/profile');
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
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
