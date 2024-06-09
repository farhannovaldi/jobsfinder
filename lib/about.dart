import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang Kami'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tentang Kami',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Job Finder adalah aplikasi yang membantu Anda menemukan pekerjaan impian Anda. Kami menyediakan platform yang menghubungkan pencari kerja dengan perusahaan-perusahaan terkemuka di berbagai industri. Dengan Job Finder, Anda dapat menjelajahi ribuan lowongan pekerjaan, melamar dengan mudah, dan mengelola riwayat pencarian pekerjaan Anda, semua dalam satu aplikasi yang mudah digunakan.',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Hubungi Kami',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Email: info@jobfinder.com',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            Text(
              'Telepon: +1234567890',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
