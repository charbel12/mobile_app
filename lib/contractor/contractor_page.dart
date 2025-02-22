import 'package:flutter/material.dart';
import 'package:resapp/tools/bottom_nav.dart';

class ContractorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Properties")),
      body: Center(child: Text("Properties page!")),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }
}
