import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resapp/tools/auth_service.dart';
import 'package:resapp/tools/bottom_nav.dart';
import 'package:resapp/auth/login_page.dart';
import 'package:resapp/tools/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/quickalert.dart';

class ProfileData {
  final String email;
  final String role;
  final String id;
  final String phoneNum;
  final String name;

  ProfileData({
    required this.email,
    required this.role,
    required this.id,
    required this.phoneNum,
    required this.name,
  });
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool edit = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _logout(BuildContext context) async {
    await _auth.signOut();
    await AuthService.setLoggedIn(false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  void _resetPassword(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _auth.sendPasswordResetEmail(email: user.email!);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'You will receive a password reset, please check your email!',
        confirmBtnText: 'Okay',
        confirmBtnColor: AppColors.res_green,
        onConfirmBtnTap: () async {
          _logout(context);
        }
      );
    }
  }

  Future<void> _loadUserData() async {
    print('loading user data');
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userData.exists) {
        _nameController.text = userData['fullName'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
      }
    }
  }

  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fullName': _nameController.text,
          'phone': _phoneController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ));

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('phoneNumber', _phoneController.text);
        prefs.setString('fullName', _nameController.text);


        // _loadUserData();
      } catch (e) {
        setState(() {
          _errorMessage = 'Error updating profile: $e';
        });
      }
      setState(() {
        edit = false;
      });
    }
  }

  Future<ProfileData> readData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? email = prefs.getString('userEmail') ?? 'N/A';
    String? role = prefs.getString('userRole') ?? 'N/A';
    String? id = prefs.getString('userId') ?? 'N/A';
    String? phoneNum = prefs.getString('phoneNumber') ?? 'N/A';
    String? name = prefs.getString('fullName') ?? 'N/A';

    return ProfileData(
        email: email, role: role, id: id, phoneNum: phoneNum, name: name);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profile"),
        actions: [
          if (edit)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateUserData,
            ),
          IconButton(

            icon: Icon(edit ?  Icons.close:  Icons.edit),
            onPressed: () {
              setState(() {
                edit = !edit;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColors.res_green,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: FutureBuilder<ProfileData>(
                future: readData(),
                builder: (context, snapshot) {
                  return snapshot.connectionState == ConnectionState.waiting
                      ? CircularProgressIndicator()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileField(
                        label: "Full Name",
                        controller: _nameController,
                        value: snapshot.data?.name ?? 'N/A',
                        enabled: edit,
                      ),
                      ProfileField(
                        label: "Phone Number",
                        controller: _phoneController,
                        value: snapshot.data?.phoneNum ?? 'N/A',
                        enabled: edit,
                      ),
                      ProfileField(
                        label: "Email",
                        controller: _emailController,
                        value: snapshot.data?.email ?? 'N/A',
                        enabled: false,
                      ),
                      Row(
                        spacing: 20,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          Expanded(child: ElevatedButton.icon(
                              onPressed: () {
                                _logout(context);
                              },
                              icon: const Icon(Icons.logout, color: Color.fromARGB(
                                  255, 0, 0, 0)), // Icon
                              label: const Text('Logout', style: TextStyle(color:Color.fromARGB(
                                  255, 0, 0, 0) )),        // Text
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))
                            ),
                          ),
                          Expanded(child: ElevatedButton.icon(
                              onPressed: () {
                                _resetPassword(context);
                              },
                              icon: const Icon(Icons.lock, color: Color.fromARGB(
                                  255, 0, 0, 0)), // Icon
                              label: const Text('Reset Password', style: TextStyle(color:Color.fromARGB(
                                  255, 0, 0, 0) )),        // Text
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12))
                          ))
                      ]
                      ),

                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 4),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final TextEditingController controller;
  final bool enabled;

  const ProfileField({
    super.key,
    required this.enabled,
    required this.label,
    required this.value,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    controller.text = value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: 'Enter your $label',
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
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
          ),
          SizedBox(height: 10),
          const Divider(),
        ],
      ),
    );
  }
}
