import 'dart:math';
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
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
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
            ...List.generate(8, (index) => _buildParticle(index)),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Transform.scale(
                      scale: _scaleAnim.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppConstants.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.gold.withAlpha((80 * _glowAnim.value).round()),
                              blurRadius: 40 + 20 * (1 - _glowAnim.value),
                              spreadRadius: 5 + 15 * (1 - _glowAnim.value),
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
                  ),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (context, child) => Opacity(
                      opacity: _fadeAnim.value,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => AppConstants.goldGradient.createShader(bounds),
                            child: Text(
                              'Royal Stay',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
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
    final random = Random(index * 7);
    final size = 4.0 + random.nextDouble() * 10;
    final startX = random.nextDouble();
    final startY = random.nextDouble();
    final driftX = (random.nextDouble() - 0.5) * 100;
    final driftY = -(random.nextDouble() * 60 + 20);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value + index * 0.12) % 1.0;
        final opacity = sin(progress * pi) * 0.4;
        final x = startX * MediaQuery.of(context).size.width + driftX * progress;
        final y = startY * MediaQuery.of(context).size.height + driftY * progress;

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: index.isEven ? AppConstants.gold : AppConstants.goldLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.gold.withAlpha(60),
                    blurRadius: size,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
