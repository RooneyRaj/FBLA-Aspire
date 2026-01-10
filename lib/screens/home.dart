import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onTabChange;

  const HomeScreen({
    super.key,
    required this.onTabChange,
  });

  Future<String> _getFirstName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return 'User';

    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .get();

    if (!doc.exists) return 'User';

    final data = doc.data()!;
    final firstName = data['first_name'] ?? 'User';

    if (firstName.isEmpty) return 'User';

    return firstName[0].toUpperCase() + firstName.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFF1442A6),
        child: Column(
          children: [
            // Header
            Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
              color: Colors.white,
              alignment: Alignment.centerLeft,
              child: Text(
                "Home",
                style: GoogleFonts.comfortaa(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      ///  Welcome with Firestore first name
                      FutureBuilder<String>(
                        future: _getFirstName(),
                        builder: (context, snapshot) {
                          final name = snapshot.data ?? ' ';

                          return Text(
                            "Welcome, $name",
                            style: GoogleFonts.comfortaa(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'What would you like to do today?',
                          style: GoogleFonts.comfortaa(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      buildProfileCard(
                        imagePath: 'assets/images/home_profile.png',
                        title: 'My Profile',
                        buttonText: 'View Profile',
                        onPressed: () => onTabChange(5),
                      ),
                      const SizedBox(height: 30),

                      buildProfileCard(
                        imagePath: 'assets/images/calendar.png',
                        title: 'Calendar',
                        buttonText: 'View Calendar',
                        onPressed: () => onTabChange(3),
                      ),
                      const SizedBox(height: 30),

                      buildProfileCard(
                        imagePath: 'assets/images/resources.png',
                        title: 'Resources',
                        buttonText: 'View Resources',
                        onPressed: () => onTabChange(4),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper function to build a profile-like card
  Widget buildProfileCard({
    required String imagePath,
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Image.asset(
                imagePath,
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.comfortaa(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1442A6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onPressed,
                    child: const Text(
                      'View',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
