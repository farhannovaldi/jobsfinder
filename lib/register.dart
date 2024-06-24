import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController =
      TextEditingController(); // Added phone controller

  final _formKey = GlobalKey<FormState>();
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword =
      true; // Added obscure state for confirm password
  bool _isLoading = false;
  String? _selectedEducation;
  final List<String> _educationLevels = [
    'SD',
    'SMP',
    'SMA',
    'D3',
    'S1',
    'S2',
    'S3'
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _togglePasswordVisibility() {
    setState(() {
      _isObscurePassword = !_isObscurePassword;
    });
  }

  // Added method to toggle visibility of confirm password
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isObscureConfirmPassword = !_isObscureConfirmPassword;
    });
  }

  Future<void> _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showDialog(context, "Kata Sandi Tidak Cocok",
          "Pastikan kata sandi dan konfirmasi kata sandi cocok.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await userCredential.user!.updateDisplayName(_nameController.text);

      // Tambahkan pesan log sebelum penyimpanan data ke Firestore
      print('Menyimpan data ke Firestore...');

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text, // Added phone number
        'address': _addressController.text,
        'education': _selectedEducation,
      });

      // Tambahkan pesan log setelah penyimpanan data ke Firestore
      print('Data berhasil disimpan ke Firestore.');

      _showDialog(
        context,
        "Pendaftaran Berhasil",
        "Akun Anda berhasil didaftarkan.",
        navigateToLogin: true,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'Password yang Anda masukkan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Akun sudah terdaftar dengan email tersebut.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email yang Anda masukkan tidak valid.';
      } else {
        errorMessage = 'Terjadi kesalahan. Silakan coba lagi nanti.';
      }
      _showDialog(context, "Pendaftaran Gagal", errorMessage);
    } catch (e) {
      // Tampilkan pesan log jika terjadi kesalahan
      print('Error saat menyimpan data ke Firestore: $e');
      _showDialog(
          context, "Error", "Terjadi kesalahan. Silakan coba lagi nanti.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(BuildContext context, String title, String content,
      {bool navigateToLogin = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (navigateToLogin) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) => LoginPage(),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                }
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
          child: Form(
            key: _formKey,
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
                _buildTextField(_emailController, 'Email', validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  return null;
                }),
                SizedBox(height: 20.0),
                _buildPasswordField(),
                SizedBox(height: 20.0),
                _buildConfirmPasswordField(),
                SizedBox(height: 20.0),
                _buildTextField(_nameController, 'Nama', validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                }),
                SizedBox(height: 20.0),
                _buildTextField(_phoneController, 'Nomor Telepon',
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                }),
                SizedBox(height: 20.0),
                _buildDropdownField(),
                SizedBox(height: 20.0),
                _buildTextField(_addressController, 'Alamat',
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                }),
                SizedBox(height: 20.0),
                _buildRegisterButton(context),
                if (_isLoading) CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, FormFieldValidator<String>? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        // Added suffix icon to toggle password visibility
        suffixIcon: obscureText
            ? IconButton(
                onPressed: () {
                  if (label == 'Password') {
                    _togglePasswordVisibility();
                  } else if (label == 'Konfirmasi Kata Sandi') {
                    _toggleConfirmPasswordVisibility();
                  }
                },
                icon:
                    Icon(obscureText ? Icons.visibility : Icons.visibility_off),
              )
            : null, // Show suffix icon only for password fields
      ),
      validator: validator,
      onFieldSubmitted: (_) {
        FocusScope.of(context).nextFocus();
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(_passwordController, 'Password',
        obscureText: _isObscurePassword, validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Password tidak boleh kosong';
      }
      if (value.length < 6) {
        return 'Password harus terdiri dari minimal 6 karakter';
      }
      return null;
    });
  }

  Widget _buildConfirmPasswordField() {
    return _buildTextField(_confirmPasswordController, 'Konfirmasi Kata Sandi',
        obscureText: _isObscureConfirmPassword, validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Konfirmasi kata sandi tidak boleh kosong';
      }
      if (value != _passwordController.text) {
        return 'Konfirmasi kata sandi tidak cocok';
      }
      return null;
    });
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pendidikan terakhir harus dipilih';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () {
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
