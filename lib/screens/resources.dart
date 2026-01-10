import 'package:fblaaspire/components/docs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Document> docs = allDocuments;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open PDF';
    }
  }

  void searchDocs(String query) {
    final suggestions = allDocuments.where((doc) {
      final title = doc.title.toLowerCase();
      final input = query.toLowerCase();
      return title.contains(input);
    }).toList();

    setState(() => docs = suggestions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Resources',
                  style: GoogleFonts.comfortaa(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search Resources',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onChanged: searchDocs,
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];

                  return ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(doc.title),
                    trailing: const Icon(Icons.download),
                    onTap: () => _openPdf(doc.fileurl),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
