import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Applications'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where('userId', isEqualTo: user?.uid ?? '')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Belum ada pekerjaan yang diapply.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot<Map<String, dynamic>> application =
                  snapshot.data!.docs[index];

              // Ambil data pekerjaan yang diapply
              String jobTitle =
                  application.data()?['jobTitle'] ?? 'Tidak ada judul';
              String jobCompany =
                  application.data()?['company'] ?? 'Tidak ada perusahaan';
              String jobLocation =
                  application.data()?['location'] ?? 'Lokasi tidak diketahui';
              String status = application.data()?['status'] ??
                  'menunggu'; // Ambil status aplikasi

              return Card(
                color: Colors.grey[900],
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    jobTitle,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$jobCompany - $jobLocation',
                        style: TextStyle(color: Colors.white54),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Aksi ketika item pekerjaan di tap (jika diperlukan)
                  },
                  trailing: status == 'ditolak'
                      ? IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteApplication(application.id);
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu':
        return Colors.orange;
      case 'diterima':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  void _deleteApplication(String applicationId) {
    FirebaseFirestore.instance
        .collection('applications')
        .doc(applicationId)
        .delete()
        .then((value) {
      print('Aplikasi berhasil dihapus');
    }).catchError((error) {
      print('Gagal menghapus aplikasi: $error');
      // Tambahkan logika penanganan kesalahan jika perlu
    });
  }
}
