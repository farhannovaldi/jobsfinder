import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _uploadCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;

      if (fileBytes != null) {
        // Upload file to Firebase Storage
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('cv/${user!.uid}/cv.${result.files.single.extension}');
        UploadTask uploadTask = storageRef.putData(fileBytes);

        await uploadTask.whenComplete(() async {
          // Get the download URL
          String downloadURL = await storageRef.getDownloadURL();

          // Update user data in Firestore with CV URL
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .update({'cvUrl': downloadURL});

          setState(() {
            userData!['cvUrl'] = downloadURL;
          });
        });
      } else {
        // Handle case where fileBytes is null
        print('File is null or cannot be read.');
      }
    }
  }

  Future<void> _launchCVURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akun'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
              ? Center(child: Text('Tidak ada data pengguna'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
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
                              _buildUserInfo('Pendidikan Terakhir',
                                  userData!['education']),
                              Divider(),
                              userData!['cvUrl'] != null
                                  ? _buildCVInfo('CV', userData!['cvUrl'])
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.upload_file),
                            onPressed: _uploadCV,
                            tooltip: 'Upload CV',
                          ),
                          Text('Upload CV', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
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

  Widget _buildCVInfo(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              _launchCVURL(url);
            },
            child: Text(
              'Lihat CV',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'URL: $url',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
