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
import 'package:resapp/tools/auth_service.dart';
import 'package:resapp/tools/validators.dart';
import 'package:resapp/tools/loading_state.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  bool _obscureText = true;
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (!user.emailVerified) {
          setState(() => _isLoading = false);
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
          Map<String, dynamic>? userData =
              await _getUserDataFromFirestore(user.uid);
          String? role = userData?['role'];
          if (userData != null) {
            await _storeUserInSession(user, userData);
            await AuthService.setLoggedIn(true);
            setState(() => _isLoading = false);
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
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? 'An error occurred. Please try again.';
      });
    }
  }

  Future<Map<String, dynamic>?> _getUserDataFromFirestore(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _storeUserInSession(User user, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userEmail', user.email ?? '');
    prefs.setString('userRole', data['role']);
    prefs.setString('userId', user.uid);
    prefs.setString('phoneNumber', data['phone'] ?? '');
    prefs.setString('fullName', data['fullName'] ?? '');
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'fullName': user.displayName ?? '',
              'email': user.email ?? '',
              'phone': user.phoneNumber ?? '',
              'role': 'user',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          Map<String, dynamic> userData = userDoc.exists
              ? userDoc.data() as Map<String, dynamic>
              : {
                  'fullName': user.displayName ?? '',
                  'email': user.email ?? '',
                  'phone': user.phoneNumber ?? '',
                  'role': 'user',
                };

          await _storeUserInSession(user, userData);
          await AuthService.setLoggedIn(true);

          setState(() => _isLoading = false);
          if (userData['role'] == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (userData['role'] == 'contractor') {
            Navigator.pushReplacementNamed(context, '/contractor');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Google Sign-In was cancelled';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error during Google Sign-In: $e';
      });
    }
  }

  Future<void> signInWithFacebook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'fullName': user.displayName ?? '',
              'email': user.email ?? '',
              'phone': user.phoneNumber ?? '',
              'role': 'user',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          Map<String, dynamic> userData = userDoc.exists
              ? userDoc.data() as Map<String, dynamic>
              : {
                  'fullName': user.displayName ?? '',
                  'email': user.email ?? '',
                  'phone': user.phoneNumber ?? '',
                  'role': 'user',
                };

          await _storeUserInSession(user, userData);
          await AuthService.setLoggedIn(true);

          setState(() => _isLoading = false);
          if (userData['role'] == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (userData['role'] == 'contractor') {
            Navigator.pushReplacementNamed(context, '/contractor');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Facebook Sign-In failed: ${result.message}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error during Facebook Sign-In: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingState(
      isLoading: _isLoading,
      loadingText: 'Please wait...',
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Login", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
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
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  validator: Validators.validateEmail,
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
                      borderSide:
                          BorderSide(color: AppColors.res_green, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  validator: Validators.validatePassword,
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
                      borderSide:
                          BorderSide(color: AppColors.res_green, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
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
                        // TODO: Implement forgot password
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
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()),
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
        ),
      ),
    );
  }
}
