import 'package:flutter/material.dart';
import 'package:resapp/bottom_nav.dart';

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Services")),
      body: Center(child: Text("Welcome to Home!")),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
    );
  }
}
