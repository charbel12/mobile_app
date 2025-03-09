import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final user = _auth.currentUser;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn && user != null;
  }

  static Future<String?> getUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        return userDoc['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  static Future<void> setLoggedIn(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', value);

      if (!value) {
        // Clear all user data from SharedPreferences when logging out
        await prefs.remove('userEmail');
        await prefs.remove('userRole');
        await prefs.remove('userId');
        await prefs.remove('phoneNumber');
        await prefs.remove('fullName');
      }
    } catch (e) {
      print('Error setting logged in status: $e');
    }
  }

  static Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await _firestore.collection('users').doc(user.uid).update(data);

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (data.containsKey('fullName')) {
        await prefs.setString('fullName', data['fullName']);
      }
      if (data.containsKey('phone')) {
        await prefs.setString('phoneNumber', data['phone']);
      }
    } catch (e) {
      print('Error updating user data: $e');
      throw e;
    }
  }

  static Future<void> refreshUserSession() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        await setLoggedIn(false);
        return;
      }

      Map<String, dynamic>? userData = await getUserData();
      if (userData == null) {
        await setLoggedIn(false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', user.email ?? '');
      await prefs.setString('userRole', userData['role'] ?? '');
      await prefs.setString('userId', user.uid);
      await prefs.setString('phoneNumber', userData['phone'] ?? '');
      await prefs.setString('fullName', userData['fullName'] ?? '');
      await setLoggedIn(true);
    } catch (e) {
      print('Error refreshing user session: $e');
      await setLoggedIn(false);
    }
  }
}
