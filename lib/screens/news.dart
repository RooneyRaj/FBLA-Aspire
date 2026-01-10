import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller inside initState
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          // No restrictions - allow all navigation
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse('https://www.fbla.org/newsroom/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.0),
            child: Container(
              color: const Color(0xFF1442A6),
              child: Column(
                children: [
                  // --- Header with Navigation Controls ---
                  Container(
                    height: 80,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "News",
                          style: GoogleFonts.comfortaa(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // Navigation Buttons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 20),
                              onPressed: () async {
                                if (await _controller.canGoBack()) {
                                  await _controller.goBack();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 24),
                              onPressed: () => _controller.reload(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, size: 20),
                              onPressed: () async {
                                if (await _controller.canGoForward()) {
                                  await _controller.goForward();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // --- WebView ---
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: WebViewWidget(controller: _controller),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}