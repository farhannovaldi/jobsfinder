import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'akun.dart'; // Import halaman akun

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
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
              // Aksi saat ikon profil ditekan
              Navigator.pushNamed(context, '/akun'); // Navigasi ke halaman akun
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
            ListTile(
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Aksi saat item Home ditekan
              },
            ),
            ListTile(
              title: const Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Aksi saat item Profile ditekan
              },
            ),
            ListTile(
              title: const Text('Saved Jobs', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/saved-jobs');
              },
            ),
            ListTile(
              title: const Text('My Applications', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Aksi saat item My Applications ditekan
              },
            ),
            ListTile(
              title: const Text('About Us', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
            ListTile(
              title: const Text('Log Out', style: TextStyle(color: Colors.white)),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
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
                // Aksi saat teks pencarian berubah
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                DropdownButton<String>(
                  dropdownColor: Colors.black,
                  hint: const Text('Location', style: TextStyle(color: Colors.white)),
                  items: <String>['Location 1', 'Location 2', 'Location 3']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (_) {
                    // Aksi saat lokasi dipilih
                  },
                ),
                DropdownButton<String>(
                  dropdownColor: Colors.black,
                  hint: const Text('Industry', style: TextStyle(color: Colors.white)),
                  items: <String>['Industry 1', 'Industry 2', 'Industry 3']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (_) {
                    // Aksi saat industri dipilih
                  },
                ),
                DropdownButton<String>(
                  dropdownColor: Colors.black,
                  hint: const Text('Experience', style: TextStyle(color: Colors.white)),
                  items: <String>['Entry Level', 'Mid Level', 'Senior Level']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                     
value: value,
                      child: Text(value, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (_) {
                    // Aksi saat tingkat pengalaman dipilih
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Jumlah pekerjaan terbaru
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    title: Text('Job Title $index', style: const TextStyle(color: Colors.white)),
                    subtitle: const Text('Company Name - Location', style: TextStyle(color: Colors.white54)),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark_border, color: Colors.white54),
                      onPressed: () {
                        // Aksi saat tombol simpan ditekan
                      },
                    ),
                    onTap: () {
                      // Aksi saat item pekerjaan ditekan
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
