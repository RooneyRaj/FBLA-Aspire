// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // won't show through

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.0),

            child: SizedBox.expand(
              child: Container(
                color: const Color(0xFF1442A6),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Connect",
                                    style: GoogleFonts.comfortaa(
                                      color: Colors.black,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  // --- Updated FBLA Logo Section ---
                                  Center(
                                    child: Image.asset(
                                      'assets/images/fblalogocolor.png',
                                      height: 220, // increased from 170 to 220
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  Center(
                                    child: Text(
                                      "Check out the latest news on our social media pages!",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.comfortaa(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5.2),
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width >= 1000
                                    ? 1000
                                    : MediaQuery.of(context).size.width - 40,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          'Social Media Platforms',
                                          style: GoogleFonts.comfortaa(
                                            fontSize: 18.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Social cards arranged in two columns
                                      GridView.count(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        childAspectRatio: 3 / 2,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    launchUrl(
                                                      Uri.parse(
                                                        'https://www.facebook.com/FutureBusinessLeaders/',
                                                      ),
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.facebook,
                                                    size: 32,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Facebook',
                                                  style: GoogleFonts.comfortaa(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              launchUrl(
                                                Uri.parse(
                                                  'https://www.instagram.com/fbla_national/',
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/insta.png',
                                                    width: 50,
                                                    height: 50,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Instagram',
                                                    style:
                                                        GoogleFonts.comfortaa(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              launchUrl(
                                                Uri.parse(
                                                  'https://x.com/FBLA_National',
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/x.png',
                                                    width: 35,
                                                    height: 35,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'X',
                                                    style:
                                                        GoogleFonts.comfortaa(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              launchUrl(
                                                Uri.parse(
                                                  'https://www.youtube.com/channel/UCsojHDEYGNSZ_qVuRSkj8sg/videos',
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/youtube.png',
                                                    width: 50,
                                                    height: 50,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Youtube',
                                                    style:
                                                        GoogleFonts.comfortaa(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 11),
                                      Center(
                                        child: Text(
                                          "Tap a platform to explore!",
                                          style: GoogleFonts.comfortaa(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
