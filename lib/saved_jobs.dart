import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedJobsPage extends StatelessWidget {
  const SavedJobsPage({Key? key}) : super(key: key);

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
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
          title: Text(job.data()?['jobTitle'] ?? 'No title'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Company: ${job.data()?['company'] ?? 'No company'}'),
              SizedBox(height: 8),
              Text(
                  'Location: ${job.data()?['location'] ?? 'Location unknown'}'),
              SizedBox(height: 8),
              Text(
                  'Description: ${job.data()?['description'] ?? 'Description not available'}'),
              SizedBox(height: 8),
              Text(
                  'Salary: ${job.data()?['salary'] ?? 'Salary not available'}'),
              SizedBox(height: 8),
              Text(
                  'Experience Level: ${job.data()?['experienceLevel'] ?? 'Level not available'}'),
              // Add additional fields as needed
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
                _removeSavedJob(job, context);
                Navigator.of(context).pop();
              },
              child: Text(
                'Remove',
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
      String jobTitle = job.data()?['jobTitle'] ?? 'No title';
      String jobCompany = job.data()?['company'] ?? 'No company';
      String jobLocation = job.data()?['location'] ?? 'Location unknown';

      FirebaseFirestore.instance.collection('applications').doc(jobId).set({
        'userId': user.uid,
        'jobTitle': jobTitle,
        'company': jobCompany,
        'location': jobLocation,
        'status': 'menunggu', // Initial application status
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

  void _removeSavedJob(
      DocumentSnapshot<Map<String, dynamic>> job, BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null && job.exists) {
      String jobId = job.id;

      FirebaseFirestore.instance
          .collection('saved_jobs')
          .doc(jobId)
          .delete()
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job Removed'),
            duration: Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        print('Failed to remove job: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove job'),
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
        title: const Text('Saved Jobs'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('saved_jobs')
                  .where('userId', isEqualTo: user!.uid)
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
                  return Center(child: Text('No saved jobs.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot<Map<String, dynamic>> job =
                        snapshot.data!.docs[index];

                    return Card(
                      color: Colors.grey[900],
                      child: ListTile(
                        title: Text(job.data()?['jobTitle'] ?? 'No title',
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(job.data()?['company'] ?? 'No company',
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
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _removeSavedJob(job, context);
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
}
