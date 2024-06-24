import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedJobsPage extends StatefulWidget {
  const SavedJobsPage({Key? key}) : super(key: key);

  @override
  _SavedJobsPageState createState() => _SavedJobsPageState();
}

class _SavedJobsPageState extends State<SavedJobsPage> {
  late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> savedJobsStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream with the saved jobs for the current user
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      savedJobsStream = FirebaseFirestore.instance
          .collection('saved_jobs')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    } else {
      savedJobsStream = Stream.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Jobs'),
      ),
      body: StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        stream: savedJobsStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>>
                snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No saved jobs yet.'));
          }

          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (context, index) {
              DocumentSnapshot<Map<String, dynamic>> job =
                  snapshot.data![index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(job.data()?['jobTitle'] ?? 'No title',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(job.data()?['company'] ?? 'No company',
                      style: TextStyle(color: Colors.white54)),
                  onTap: () {
                    _showJobDetails(context, job);
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteJob(job);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
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
                  'Description: ${job.data()?['description'] ?? 'No description'}'),
              SizedBox(height: 8),
              Text('Salary: ${job.data()?['salary'] ?? 'Salary unknown'}'),
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
            // You can add more actions here if needed
          ],
        );
      },
    );
  }

  void _deleteJob(DocumentSnapshot<Map<String, dynamic>> job) {
    FirebaseFirestore.instance
        .collection('saved_jobs')
        .doc(job.id)
        .delete()
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job Deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      print('Failed to delete job: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete job'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
