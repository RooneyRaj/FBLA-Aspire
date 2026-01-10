import 'package:fblaaspire/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Hide system UI safely
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Wait until the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut)).animate(animation);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 1300),
      ),
    );
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1442A6),
      body: Center(
        child: SizedBox(
          height: 400,
          width: 400,
          child: Image.asset('assets/images/fblalogowhite.png'),
        ),
      ),
    );
  }
}
