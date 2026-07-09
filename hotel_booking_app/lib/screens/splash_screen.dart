import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );
    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final guestId = prefs.getString('guestId');
    if (guestId != null && guestId.isNotEmpty) {
      final guestName = prefs.getString('guestName') ?? 'Guest';
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => MainScreen(guestId: guestId, guestName: guestName),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppConstants.backgroundGradient,
        ),
        child: Stack(
          children: [
            ...List.generate(5, (index) => _buildParticle(index)),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _scaleAnim,
                    builder: (context, child) => Transform.scale(
                      scale: _scaleAnim.value,
                      child: child,
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppConstants.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.gold.withAlpha(80),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hotel_class,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (context, child) => Opacity(
                      opacity: _fadeAnim.value,
                      child: child,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Royal Stay',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Luxury Hotel & Resorts',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppConstants.goldLight,
                            letterSpacing: 4,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (context, child) => Opacity(
                      opacity: _fadeAnim.value * 0.6,
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppConstants.gold,
                        ),
                      ),
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

  Widget _buildParticle(int index) {
    final positions = [
      const Alignment(-0.8, -0.7),
      const Alignment(0.7, -0.6),
      const Alignment(-0.5, 0.7),
      const Alignment(0.8, 0.5),
      const Alignment(0.0, -0.9),
    ];
    final sizes = [8.0, 12.0, 6.0, 10.0, 14.0];
    final delays = [0, 400, 800, 200, 600];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value * 2 + delays[index] / 1000) % 2;
        final opacity = (1 - (progress - 1).abs()) * 0.3;
        return Container(
          alignment: positions[index],
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: sizes[index],
              height: sizes[index],
              decoration: BoxDecoration(
                color: AppConstants.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
