import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../models/guest_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String guestId;

  const ProfileScreen({super.key, required this.guestId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _apiService = ApiService();
  GuestModel? _guest;
  bool _isLoading = true;
  String? _error;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _loadProfile();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('guestPhone');
      if (phone != null) {
        _guest = await _apiService.findGuestByPhone(phone);
      }
      if (_guest == null) {
        _guest = await _apiService.findGuestByPhone('');
      }
      _animController.forward();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Logout?',
          style: GoogleFonts.playfairDisplay(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(color: AppConstants.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppConstants.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout', style: GoogleFonts.inter(color: AppConstants.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('guestId');
      await prefs.remove('guestName');
      await prefs.remove('guestPhone');
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppConstants.backgroundGradient),
        child: SafeArea(
          child: _isLoading
              ? _buildLoading()
              : _error != null
                  ? _buildError()
                  : _guest == null
                      ? _buildNoGuest()
                      : AnimatedBuilder(
                          animation: _fadeAnim,
                          builder: (context, child) => Opacity(
                            opacity: _fadeAnim.value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - _fadeAnim.value)),
                              child: child,
                            ),
                          ),
                          child: _buildProfile(),
                        ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppConstants.gold),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.white.withAlpha(50)),
            const SizedBox(height: 16),
            Text(
              'Could not load profile',
              style: GoogleFonts.playfairDisplay(fontSize: 20, color: AppConstants.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.inter(fontSize: 13, color: AppConstants.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _loadProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppConstants.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoGuest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.white.withAlpha(50)),
            const SizedBox(height: 16),
            Text(
              'Guest not found',
              style: GoogleFonts.playfairDisplay(fontSize: 20, color: AppConstants.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final guest = _guest!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppConstants.goldGradient,
              boxShadow: [
                BoxShadow(
                  color: AppConstants.gold.withAlpha(60),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: AppConstants.cardDark,
              child: Text(
                guest.fullName.isNotEmpty ? guest.fullName[0].toUpperCase() : 'G',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.gold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            guest.fullName,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            guest.email,
            style: GoogleFonts.inter(
              color: AppConstants.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoCard(guest),
          const SizedBox(height: 20),
          _buildLogoutButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoCard(GuestModel guest) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [AppConstants.cardDark, AppConstants.cardDark.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withAlpha(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _infoTile(Icons.phone, 'Phone', guest.phone),
          _infoTile(Icons.email, 'Email', guest.email),
          _infoTile(Icons.badge, 'ID Proof', '${guest.idProofType} • ${guest.idProofNumber}'),
          if (guest.address.isNotEmpty) _infoTile(Icons.location_on, 'Address', guest.address),
          _infoTile(Icons.tag, 'Guest ID', guest.id),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.gold.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppConstants.gold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppConstants.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: AppConstants.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          'Logout',
          style: GoogleFonts.inter(
            color: AppConstants.redAccent,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppConstants.redAccent.withAlpha(80)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppConstants.redAccent.withAlpha(10),
        ),
      ),
    );
  }
}
