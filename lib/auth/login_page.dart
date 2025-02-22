import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:resapp/auth/sign_up_page.dart';
import 'package:quickalert/quickalert.dart';
import 'package:resapp/tools/progress_indicator.dart';
import 'package:resapp/tools/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _obscureText = true;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Email and password are required.';
      });
      return;
    }
    showLoadingDialog(context, 'Signing In');
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (!user.emailVerified) {
          hideLoadingDialog(context);
          QuickAlert.show(
            context: context,
            title: 'Account is not yet verified!',
            confirmBtnColor: AppColors.res_green,
            headerBackgroundColor: AppColors.res_green,
            showCancelBtn: true,
            cancelBtnText: 'Resend',
            confirmBtnText: 'Close',
            onCancelBtnTap: () async {
              await user.sendEmailVerification();
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
            onConfirmBtnTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
            type: QuickAlertType.info,
          );
        } else {
          Map<String,dynamic>? userData = await _getUserDataFromFirestore(user.uid);
          String? role = userData?['role'];
          if (userData != null) {
            await _storeUserInSession(user, userData);
            hideLoadingDialog(context);
            if (role == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin');
            } else if (role == 'contractor') {
              Navigator.pushReplacementNamed(context, '/contractor');
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      hideLoadingDialog(context);
      setState(() {
        _errorMessage = e.message ?? 'An error occurred. Please try again.';
      });
    }
  }

  Future<Map<String,dynamic>?> _getUserDataFromFirestore(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        return userData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _storeUserInSession(User user, Map<String,dynamic> data ) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userEmail', user.email ?? '');
    prefs.setString('userRole', data['role']);
    prefs.setString('userId', user.uid);
    prefs.setString('phoneNumber', data['phone'] ?? '');
    prefs.setString('fullName', data['fullName'] ?? '');
    prefs.setString('userId', user.uid);
  }


  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      print('Google Sign-In canceled');
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }


  Future<void> signInWithFacebook() async {
    print('Signing in with Facebook...');
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        print('Facebook Sign-In successful');

        final AccessToken accessToken = result.accessToken!;
        print('Facebook Access Token: ${accessToken.token}');

        // Create a Firebase credential from the Facebook access token
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);

        // Sign in to Firebase with the credential
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        print('Firebase Sign-In successful: ${userCredential.user?.displayName}');
      } else if (result.status == LoginStatus.cancelled) {
        print('Facebook Sign-In canceled');
      } else {
        print('Facebook Sign-In failed: ${result.message}');
      }
    } catch (e) {
      print('Error during Facebook Sign-In: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 200,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Welcome!',
              style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.res_green, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.res_green, width: 2.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText; // Toggle the password visibility
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.res_green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.res_green,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                "Login",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member? ",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpPage()),
                          );
                        },
                        child: Text(
                          "Register now",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.res_green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Divider(thickness: 1),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey),
                        ),
                        child: Image.asset(
                          'assets/google_logo.png',
                          height: 24,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.grey),
                        ),
                        child: Image.asset(
                          'assets/apple_logo.png',
                          height: 24,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: signInWithFacebook,
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                        ),
                        child: Image.asset(
                          'assets/facebook_logo.png',
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
