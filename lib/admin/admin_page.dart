import 'package:flutter/material.dart';
import 'package:resapp/admin/admin_nav.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin")),
      body: Center(child: Text("Admin page!")),
      bottomNavigationBar: AdminNav(currentIndex: 0),
    );
  }
}
