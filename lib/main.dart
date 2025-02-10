import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:resapp/login_page.dart';
import 'package:resapp/home_page.dart';
import 'package:resapp/auth_service.dart';
import 'package:resapp/add_page.dart';
import 'package:resapp/properties_page.dart';
import 'package:resapp/services_page.dart';
import 'package:resapp/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // bool isLoggedIn = await AuthService.isLoggedIn();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromRGBO(255, 255, 255, 255),
      ),
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/properties': (context) => PropertiesPage(),
        '/add': (context) => AddPage(),
        '/services': (context) => ServicesPage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}

// class MyApp extends StatelessWidget {
//   // final bool isLoggedIn;

//   // MyApp({required this.isLoggedIn});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Firebase Auth',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomePage(),
//       routes: {
//         '/login': (context) => LoginPage(),
//         '/home': (context) => HomePage(),
//         '/properties': (context) => PropertiesPage(),
//         '/add': (context) => AddPage(),
//         '/services': (context) => ServicesPage(),
//         '/profile': (context) => ProfilePage(),
//       },
//     );
//   }
// }
