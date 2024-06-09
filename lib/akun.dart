import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AkunPage extends StatelessWidget {
  const AkunPage({Key? key}) : super(key: key);

  Future<void> _showAccountInfo(BuildContext context, User? user) async {
    if (user != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Informasi Akun'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${user.email}'),
                SizedBox(height: 8),
                // Tambahkan informasi akun lainnya sesuai kebutuhan
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Tutup'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Akun'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showAccountInfo(context, user);
          },
          child: Text('Lihat Informasi Akun'),
        ),
      ),
    );
  }
}
