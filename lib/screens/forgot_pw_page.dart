// ignore_for_file: use_build_context_synchronously, sort_child_properties_last

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}


class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

Future<void> passwordReset() async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: _emailController.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset email sent successfully')),
    );
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Password reset failed: Invalid email address or user not found')),
    );
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF1442A6),
        elevation: 0,
        title: Text(
          'Forgot Password',
          style: GoogleFonts.comfortaa(
              fontSize: 23.0,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                height: 300, 
                width: 300,
                child: Image.asset('assets/images/fblalogocolor.png'),
              ),
            ),
            
            Center(
              child: Text(
                'Enter your email and we will send a password reset link!',
                textAlign: TextAlign.center,
                style: GoogleFonts.comfortaa(
                  fontSize: 21.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),  
            
            const SizedBox(height: 20),

            MaterialButton(onPressed: () {passwordReset();},
              child: const Text('Reset Password'),
              color: const Color(0xFF1442A6),
              textColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}