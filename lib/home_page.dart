import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showJobDetails(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>> job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(job.data()?['title'] ?? 'Tidak ada judul'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Company: ${job.data()?['company'] ?? 'Tidak ada perusahaan'}'),
              SizedBox(height: 8),
              Text(
                  'Location: ${job.data()?['location'] ?? 'Lokasi tidak diketahui'}'),
              SizedBox(height: 8),
              Text(
                  'Description: ${job.data()?['description'] ?? 'Deskripsi tidak tersedia'}'),
              SizedBox(height: 8),
              Text('Salary: ${job.data()?['salary'] ?? 'Gaji tidak tersedia'}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Back',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                _applyForJob(job, context);
                Navigator.of(context).pop();
              },
              child: Text(
                'Apply',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                _saveJob(job, context);
                Navigator.of(context).pop();
              },
              child: Text(
                'Save Job',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  void _applyForJob(
      DocumentSnapshot<Map<String, dynamic>> job, BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null && job.exists) {
      String jobId = job.id;
      String jobTitle = job.data()?['title'] ?? 'Tidak ada judul';
      String jobCompany = job.data()?['company'] ?? 'Tidak ada perusahaan';
      String jobLocation = job.data()?['location'] ?? 'Lokasi tidak diketahui';

      FirebaseFirestore.instance.collection('applications').doc(jobId).set({
        'userId': user.uid,
        'jobTitle': jobTitle,
        'company': jobCompany,
        'location': jobLocation,
        'status': 'menunggu', // Status awal aplikasi
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job Applied'),
            duration: Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        print('Failed to apply for job: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply for job'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  void _saveJob(
      DocumentSnapshot<Map<String, dynamic>> job, BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null && job.exists) {
      String jobId = job.id;
      String jobTitle = job.data()?['title'] ?? 'Tidak ada judul';
      String jobCompany = job.data()?['company'] ?? 'Tidak ada perusahaan';
      String jobLocation = job.data()?['location'] ?? 'Lokasi tidak diketahui';

      FirebaseFirestore.instance.collection('saved_jobs').doc(jobId).set({
        'userId': user.uid,
        'jobTitle': jobTitle,
        'company': jobCompany,
        'location': jobLocation,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job Saved'),
            duration: Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        print('Failed to save job: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save job'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/akun');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Text('Job Finder', style: TextStyle(color: Colors.white)),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
            _buildDrawerItem(icon: Icons.home, title: 'Home', onTap: () {}),
            _buildDrawerItem(
                icon: Icons.account_circle,
                title: 'Profile',
                onTap: () {
                  Navigator.pushNamed(context, '/akun');
                }),
            _buildDrawerItem(
                icon: Icons.bookmark,
                title: 'Saved Jobs',
                onTap: () {
                  Navigator.pushNamed(context, '/saved-jobs');
                }),
            _buildDrawerItem(
                icon: Icons.work,
                title: 'My Applications',
                onTap: () {
                  Navigator.pushNamed(context, '/aplikasi');
                }),
            _buildDrawerItem(
                icon: Icons.info,
                title: 'About Us',
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                }),
            _buildDrawerItem(
                icon: Icons.logout,
                title: 'Log Out',
                onTap: () {
                  _showLogoutDialog(context);
                }),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for jobs...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                // Action when search text changes
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildDropdownButton(
                    hintText: 'Location',
                    items: ['Location 1', 'Location 2', 'Location 3']),
                _buildDropdownButton(
                    hintText: 'Industry',
                    items: ['Industry 1', 'Industry 2', 'Industry 3']),
                _buildDropdownButton(
                    hintText: 'Experience',
                    items: ['Entry Level', 'Mid Level', 'Senior Level']),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Tidak ada pekerjaan.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot<Map<String, dynamic>> job =
                        snapshot.data!.docs[index];

                    return Card(
                      color: Colors.grey[900],
                      child: ListTile(
                        title: Text(job.data()?['title'] ?? 'Tidak ada judul',
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                            job.data()?['company'] ?? 'Tidak ada perusahaan',
                            style: TextStyle(color: Colors.white54)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.info_outline,
                                  color: Colors.white54),
                              onPressed: () {
                                _showJobDetails(context, job);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.bookmark,
                                  color: Colors.orange),
                              onPressed: () {
                                _saveJob(job, context);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // Action when job item is pressed
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String title,
      required void Function() onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildDropdownButton(
      {required String hintText, required List<String> items}) {
    return DropdownButton<String>(
      dropdownColor: Colors.black,
      hint: Text(hintText, style: TextStyle(color: Colors.white)),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (_) {
        // Action when dropdown item is selected
      },
    );
  }
}
