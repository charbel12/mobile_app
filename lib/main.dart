import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resapp/tools/auth_service.dart';
import 'package:resapp/tools/error_boundary.dart';
import 'package:resapp/tools/connectivity_service.dart';
import 'package:resapp/auth/login_page.dart';
import 'package:resapp/home_page.dart';
import 'package:resapp/admin/admin_page.dart';
import 'package:resapp/contractor/contractor_page.dart';
import 'package:resapp/properties_page.dart';
import 'package:resapp/services_page.dart';
import 'package:resapp/profile_page.dart';
import 'package:resapp/admin/add-service.dart';
import 'package:resapp/admin/services.dart';
import 'package:resapp/admin/admin_profile.dart';
import 'package:resapp/property/property_sale.dart';
import 'package:resapp/property/property_rent.dart';
import 'package:resapp/property/property_exchange.dart';
import 'package:resapp/property/land_sale.dart';
import 'package:resapp/property/land_rent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultHome =
      Scaffold(body: Center(child: CircularProgressIndicator()));
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print("User is logged in: ${user.email}");
      String? role = await AuthService.getUserRole();

      setState(() {
        if (role == 'admin') {
          _defaultHome = AdminPage();
        } else if (role == 'contractor') {
          _defaultHome = ContractorPage();
        } else {
          _defaultHome = HomePage();
        }
      });
      prefs.setBool('isLoggedIn', true);
    } else {
      print("User is logged out");
      setState(() {
        _defaultHome = LoginPage();
      });
      prefs.setBool('isLoggedIn', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: MaterialApp(
        scaffoldMessengerKey: _scaffoldMessengerKey,
        title: 'Flutter Firebase Auth',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        builder: (context, child) {
          return ConnectivityWrapper(
            offlineWidget: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Internet Connection',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please check your connection and try again',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            child: child!,
          );
        },
        home: _defaultHome,
        routes: {
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/services': (context) => ServicesPage(),
          '/contractor': (context) => ContractorPage(),
          '/properties': (context) => PropertiesPage(),
          '/property-sale': (context) => PropertySalePage(),
          '/property-rent': (context) => PropertyRentPage(),
          '/property-exchange': (context) => PropertyExchangePage(),
          '/land-sale': (context) => LandSalePage(),
          '/land-rent': (context) => LandRentPage(),
          '/profile': (context) => ProfilePage(),
          '/admin': (context) => AdminPage(),
          '/admin/services': (context) => AdminServicePage(),
          '/admin/profile': (context) => AdminProfilePage(),
          '/admin/add-service': (context) => AddServicePage(),
        },
      ),
    );
  }
}
