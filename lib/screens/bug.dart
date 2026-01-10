import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class BugScreen extends StatefulWidget {
  const BugScreen({super.key});

  @override
  State<BugScreen> createState() => _BugScreenState();
}

class _BugScreenState extends State<BugScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _subController = TextEditingController();

  Future <void> sendEmail() async {
    String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
// ···
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'rajrooney02@gmail.com',
    query: encodeQueryParameters(<String, String>{
      'subject': 'Bug to Fix In ${_subController.text}',
      'body': _textController.text,
    
    }),
  );
  launchUrl(emailLaunchUri);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: SizedBox(
                height: 180,
                width: 180,
                child: Image.asset('assets/images/fblalogocolor.png'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Let us know what the bug is and we will get right on it!',
              textAlign: TextAlign.center,
              style: GoogleFonts.comfortaa(
                fontSize: 21.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: _subController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Location of the Bug...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: _textController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'What is the Bug...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            MaterialButton(
              onPressed: sendEmail,
              color: const Color(0xFF1442A6),
              textColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Insert in Email'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
