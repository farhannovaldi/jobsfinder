import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isObscure = true;

  String? _selectedEducation;
  final List<String> _educationLevels = ['SD', 'SMP', 'SMA', 'D3', 'S1','S2','S3'];

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().catchError((error) {
      // Handle Firebase initialization error
      print("Firebase initialization error: $error");
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> _register(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': _nameController.text,
        'education': _selectedEducation,
        'address': _addressController.text,
      });

      _showDialog(context, "Pendaftaran Berhasil", "Akun Anda berhasil terdaftar.");
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'Password yang Anda masukkan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Akun sudah terdaftar dengan email tersebut.';
      } else {
        errorMessage = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      }
      _showDialog(context, "Pendaftaran Gagal", errorMessage);
    } catch (e) {
      _showDialog(context, "Error", "Terjadi kesalahan. Silakan coba lagi nanti.");
    }
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Finder - Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Join Job Finder',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              _buildTextField(_emailController, 'Email'),
              SizedBox(height: 20.0),
              _buildPasswordField(),
              SizedBox(height: 20.0),
              _buildTextField(_nameController, 'Nama'),
              SizedBox(height: 20.0),
              _buildDropdownField(),
              SizedBox(height: 20.0),
              _buildTextField(_addressController, 'Alamat'),
              SizedBox(height: 20.0),
              _buildRegisterButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      onSubmitted: (_) {
        FocusScope.of(context).nextFocus();
      },
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _isObscure,
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          onPressed: _togglePasswordVisibility,
          icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      onSubmitted: (_) {
        FocusScope.of(context).nextFocus();
      },
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Pendidikan Terakhir',
      ),
      value: _selectedEducation,
      items: _educationLevels.map((String level) {
        return DropdownMenuItem<String>(
          value: level,
          child: Text(level),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedEducation = newValue;
        });
      },
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _register(context);
      },
      child: Text(
        'Register',
        style: TextStyle(color: Colors.black),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    );
  }
}
