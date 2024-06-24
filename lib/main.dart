import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jobsfinder/login.dart';
import 'firebase_options.dart';
import 'about.dart';
import 'home_page.dart';
import 'akun.dart';
import 'application.dart';
import 'saved_jobs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Job Finder',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.black,
          secondary: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          color: Colors.black,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          prefixIconColor: Colors.white54,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.black,
          scrimColor: Colors.white10,
        ),
        cardColor: Colors.grey[900],
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/about': (context) => AboutPage(),
        '/akun': (context) => AkunPage(),
        '/aplikasi': (context) => ApplicationsPage(),
        '/saved-jobs': (context) => SavedJobsPage(),
      },
    );
  }
}
