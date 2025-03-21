import 'package:flutter/material.dart';
import 'package:resapp/auth/login_page.dart';
import 'package:resapp/tools/auth_service.dart';

class RouteGuard {
  static Future<bool> canActivate(
      BuildContext context, Set<String> allowedRoles) async {
    bool isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return false;
    }

    if (allowedRoles.isEmpty) {
      return true;
    }

    String? userRole = await AuthService.getUserRole();
    if (userRole == null || !allowedRoles.contains(userRole)) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('You do not have permission to access this page')),
      );
      return false;
    }

    return true;
  }
}
