import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_nav.dart';

class AdminContractors extends StatefulWidget {
  @override
  _AdminContractorsState createState() => _AdminContractorsState();
}

class _AdminContractorsState extends State<AdminContractors> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _editingId;

  void _addOrUpdateContractor() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty || _passwordController.text.isEmpty) return;

    if (_editingId == null) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        FirebaseFirestore.instance.collection('contractors').doc(userCredential.user!.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'createdAt': Timestamp.now(),
        });
        FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'createdAt': Timestamp.now(),
          'role': 'contractor'
        });
      } catch (e) {
        print('Error creating user: $e');
      }
    } else {
      FirebaseFirestore.instance.collection('contractors').doc(_editingId).update({
        'fullName': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      });
      FirebaseFirestore.instance.collection('users').doc(_editingId).update({
        'fullName': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      });
    }

    _clearFields();
  }

  void _editContractor(DocumentSnapshot doc) {
    setState(() {
      _editingId = doc.id;
      _nameController.text = doc['name'];
      _emailController.text = doc['email'];
      _phoneController.text = doc['phone'];
    });
  }

  void _deleteContractor(String id) async {
    print('Deleting user with id: $id');
    try {
      await FirebaseFirestore.instance.collection('contractors').doc(id).delete();
      await FirebaseFirestore.instance.collection('users').doc(id).delete();
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        print('User deleted from Firebase Auth.');
      } else {
        print('User with ID $id not found in FirebaseAuth.');
      }
    } catch (e) {
      print('Error deleting contractor: $e');
    }
  }

  void _clearFields() {
    setState(() {
      _editingId = null;
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Contractors')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(onPressed: _addOrUpdateContractor, child: Text(_editingId == null ? 'Add Contractor' : 'Update Contractor')),
                SizedBox(width: 10),
                if (_editingId != null)
                  ElevatedButton(onPressed: _clearFields, child: Text('Cancel')),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('contractors').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text('Error loading contractors'));
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('No contractors available'));

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name']),
                        subtitle: Text('${data['email']} - ${data['phone']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: Icon(Icons.edit), onPressed: () => _editContractor(doc)),
                            IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteContractor(doc.id)),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminNav(currentIndex: 2),
    );
  }
}
