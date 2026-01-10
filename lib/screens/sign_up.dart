// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fblaaspire/screens/login_page.dart';
import 'package:fblaaspire/homepage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      FirebaseFirestore.instance
      .collection("Users")
      .doc(userCredential.user?.email)
      .set({
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "username": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed up: ${userCredential.user?.email ?? ''}')),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePageScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign up failed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up failed')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Sign Up',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!v.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => signUp(),
                      decoration: const InputDecoration(
                        hintText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _isLoading ? null : signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1442A6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder:  (context) => const LoginPage()));
                          },
                          child: const Text('Log In'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
