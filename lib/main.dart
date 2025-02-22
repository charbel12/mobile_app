import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resapp/tools/auth_service.dart';
import 'package:resapp/auth/login_page.dart';
import 'package:resapp/home_page.dart';
import 'package:resapp/admin/admin_page.dart';
import 'package:resapp/contractor/contractor_page.dart';
import 'package:resapp/add_page.dart';
import 'package:resapp/properties_page.dart';
import 'package:resapp/services_page.dart';
import 'package:resapp/profile_page.dart';
import 'package:resapp/admin/add-service.dart';
import 'package:resapp/admin/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {

      print("User is logged out, possibly after a password reset.");
    } else {
      print("User is logged in: ${user.email}");
    }
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultHome = Scaffold(body: Center(child: CircularProgressIndicator()));

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String? role = await AuthService.getUserRole();

        if (role == 'admin') {
          _defaultHome = AdminPage();
        } else if (role == 'contractor') {
          _defaultHome = ContractorPage();
        } else {
          _defaultHome = HomePage();
        }
      } else {
        _defaultHome = LoginPage();
      }
    } else {
      _defaultHome = LoginPage();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _defaultHome,
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/services': (context) => ServicesPage(),
        '/contractor': (context) => ContractorPage(),
        '/properties': (context) => PropertiesPage(),
        '/add-property': (context) => AddProperty(),
        '/profile': (context) => ProfilePage(),
        '/admin': (context) => AdminPage(),
        '/admin/services': (context) => AdminServicePage(),
        '/admin/add-service': (context) => AddServicePage(),
      },
    );
  }
}
