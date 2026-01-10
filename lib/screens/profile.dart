// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Helper function to capitalize first letter
String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController(text: "");
  final TextEditingController _lastNameController = TextEditingController(text: "");
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = currentUser?.email ?? '';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final String? userEmail = currentUser?.email;
    if (userEmail == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .get();

      if (userDoc.exists && mounted) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _firstNameController.text = capitalize(data['first_name'] ?? "");
          _lastNameController.text = capitalize(data['last_name'] ?? "");
        });
      } else if (mounted) {
        setState(() {
          _firstNameController.text = "User not found";
          _lastNameController.text = "";
        });
      }
    } catch (e) {
      debugPrint("Firestore Error: $e");
      if (mounted) {
        setState(() {
          _firstNameController.text = "Error";
          _lastNameController.text = "";
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _reauthenticateUser(String currentPassword) async {
    try {
      final credential = EmailAuthProvider.credential(
          email: currentUser!.email!, password: currentPassword);
      await currentUser!.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Re-authentication failed: ${e.message}')));
      return false;
    }
  }

  Future<void> _saveChanges() async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Ask for current password for sensitive operations
    if (newEmail != currentUser?.email || newPassword.isNotEmpty) {
      if (_currentPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter current password to proceed')));
        return;
      }
      bool success = await _reauthenticateUser(_currentPasswordController.text);
      if (!success) return;
    }

    try {
      // Update Firestore document
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.email) // old email
            .update({
          'first_name': capitalize(_firstNameController.text),
          'last_name': capitalize(_lastNameController.text),
        });
      }

      // Update email if changed
      if (newEmail != currentUser?.email && newEmail.isNotEmpty) {
        await currentUser!.updateEmail(newEmail);
        await currentUser!.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Email updated! Verification email sent to $newEmail.')),
        );
      }

      // Update password if provided
      if (newPassword.isNotEmpty) {
        await currentUser!.updatePassword(newPassword);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      setState(() {}); // refresh UI
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Container(
                color: const Color.fromARGB(255, 254, 254, 254),
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Profile",
                        style: GoogleFonts.comfortaa(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        children: [
                          Image.asset('assets/images/profile.png',
                              width: 140, height: 130),
                          const SizedBox(height: 16),

                          // Full Name Display
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _firstNameController,
                            builder: (context, firstValue, child) {
                              return ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _lastNameController,
                                builder: (context, lastValue, child) {
                                  return Text(
                                    "${capitalize(firstValue.text)} ${capitalize(lastValue.text)}"
                                        .trim(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.comfortaa(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1442A6),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 35),

                          const Text(
                            "Edit Account Info",
                            style: TextStyle(
                                color: Color(0xFF707070),
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          // First Name
                          TextField(
                            controller: _firstNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: "First Name",
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Last Name
                          TextField(
                            controller: _lastNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: "Last Name",
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Current Password (required for email/password changes)
                          TextField(
                            controller: _currentPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Current Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextField(
                            controller: _emailController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[200],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // New Password
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "New Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Confirm New Password",
                              prefixIcon: const Icon(Icons.lock_reset),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1442A6),
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Save Changes",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ],
                      ),
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
