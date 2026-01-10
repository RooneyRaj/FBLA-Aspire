// ignore_for_file: use_build_context_synchronously

import 'package:fblaaspire/screens/bug.dart';
import 'package:fblaaspire/screens/calendar.dart';
import 'package:fblaaspire/screens/connect.dart';
import 'package:fblaaspire/screens/home.dart';
import 'package:fblaaspire/screens/news.dart';
import 'package:fblaaspire/screens/profile.dart';
import 'package:fblaaspire/screens/resources.dart';
import 'package:fblaaspire/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    HomeScreen(
      onTabChange: (index) {
        setState(() => _selectedIndex = index);
      },
    ),
    const ConnectScreen(),
    NewsScreen(),
    const CalendarScreen(),
    const ResourcesScreen(),
    const ProfileScreen(),
    const BugScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1442A6),

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1442A6),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'FBLA Aspire',
          style: GoogleFonts.comfortaa(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectedIndex != 0 && _selectedIndex != 5)
            IconButton(
              icon: const Icon(Icons.person_rounded),
              onPressed: () {
                setState(() => _selectedIndex = 5);
              },
            ),
          if (_selectedIndex != 6)
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed:() {
              setState(() => _selectedIndex = 6);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out successfully')),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign out failed')),
                );
              }
            },
          ),
        ],
      ),

      // ---------------- BODY ----------------
      body: _pages[_selectedIndex],

      // ---------------- BOTTOM NAV ----------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 25,
          left: 10,
          right: 10,
          top: 14,
        ),
        child: SizedBox(
          height: 70,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: GNav(
              backgroundColor: Colors.white,
              tabBackgroundColor: Colors.grey.shade200,
              gap: 8,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() => _selectedIndex = index);
              },
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                  textStyle:
                      GoogleFonts.comfortaa(fontWeight: FontWeight.w800),
                ),
                GButton(
                  icon: Icons.search,
                  text: 'Connect',
                  textStyle:
                      GoogleFonts.comfortaa(fontWeight: FontWeight.w800),
                ),
                GButton(
                  icon: Icons.feed,
                  text: 'News',
                  textStyle:
                      GoogleFonts.comfortaa(fontWeight: FontWeight.w800),
                ),
                GButton(
                  icon: Icons.calendar_today,
                  text: 'Calendar',
                  textStyle:
                      GoogleFonts.comfortaa(fontWeight: FontWeight.w800),
                ),
                GButton(
                  icon: Icons.folder,
                  text: 'Resources',
                  textStyle:
                      GoogleFonts.comfortaa(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
