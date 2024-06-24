import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({Key? key}) : super(key: key);

  @override
  _AkunPageState createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akun'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                user?.photoURL ?? 'https://via.placeholder.com/150',
              ),
              radius: 20.0,
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
              ? Center(child: Text('Tidak ada data pengguna'))
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Akun',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20.0),
                            _buildUserInfo('Nama', userData!['name']),
                            Divider(),
                            _buildUserInfo('Email', userData!['email']),
                            Divider(),
                            _buildUserInfo(
                                'Nomor Telepon', userData!['phoneNumber']),
                            Divider(),
                            _buildUserInfo('Alamat', userData!['address']),
                            Divider(),
                            _buildUserInfo(
                                'Pendidikan Terakhir', userData!['education']),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildUserInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
