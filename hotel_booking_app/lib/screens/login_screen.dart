import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../models/guest_model.dart';
import '../widgets/custom_button.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = ApiService();

  final _signInPhoneController = TextEditingController();
  bool _isSigningIn = false;

  final _signUpFirstNameController = TextEditingController();
  final _signUpLastNameController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpIdProofNumberController = TextEditingController();
  final _signUpAddressController = TextEditingController();
  String _idProofType = 'Aadhaar';
  bool _isSigningUp = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    _signInPhoneController.dispose();
    _signUpFirstNameController.dispose();
    _signUpLastNameController.dispose();
    _signUpPhoneController.dispose();
    _signUpEmailController.dispose();
    _signUpIdProofNumberController.dispose();
    _signUpAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final phone = _signInPhoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack('Please enter your phone number');
      return;
    }
    setState(() => _isSigningIn = true);
    try {
      final guest = await _apiService.findGuestByPhone(phone);
      if (!mounted) return;
      if (guest != null) {
        await _saveSession(guest);
        _goHome(guest.fullName, guest.id);
      } else {
        setState(() => _isSigningIn = false);
        _showSnack('No account found. Please Sign Up first.');
        _tabController.animateTo(1);
        _signUpPhoneController.text = phone;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSigningIn = false);
      _showSnack('Cannot connect. Make sure backend is running on http://localhost:8080');
    }
  }

  Future<void> _handleSignUp() async {
    if (_signUpFirstNameController.text.trim().isEmpty ||
        _signUpLastNameController.text.trim().isEmpty ||
        _signUpPhoneController.text.trim().isEmpty ||
        _signUpEmailController.text.trim().isEmpty ||
        _signUpIdProofNumberController.text.trim().isEmpty) {
      _showSnack('Please fill all required fields');
      return;
    }
    setState(() => _isSigningUp = true);
    try {
      final guestData = {
        'firstName': _signUpFirstNameController.text.trim(),
        'lastName': _signUpLastNameController.text.trim(),
        'phone': _signUpPhoneController.text.trim(),
        'email': _signUpEmailController.text.trim(),
        'idProofType': _idProofType,
        'idProofNumber': _signUpIdProofNumberController.text.trim(),
        'address': _signUpAddressController.text.trim(),
      };
      final guest = await _apiService.registerGuest(guestData);
      if (!mounted) return;
      await _saveSession(guest);
      _goHome(guest.fullName, guest.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSigningUp = false);
      _showSnack('Cannot connect. Make sure backend is running on http://localhost:8080');
    }
  }

  Future<void> _saveSession(GuestModel guest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('guestId', guest.id);
    await prefs.setString('guestName', guest.fullName);
    await prefs.setString('guestPhone', guest.phone);
  }

  void _goHome(String name, String id) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainScreen(guestId: id, guestName: name),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter()),
      backgroundColor: AppConstants.cardDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppConstants.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildTabCard(),
                    const SizedBox(height: 32),
                    _buildDivider(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppConstants.goldGradient,
            boxShadow: [
              BoxShadow(
                color: AppConstants.gold.withAlpha(80),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.hotel, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => AppConstants.goldGradient.createShader(bounds),
          child: Text(
            'Grand Hotel',
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Luxury stays at your fingertips',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppConstants.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTabCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            AppConstants.cardDark,
            Color(0xFF151B2E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _buildTabToggle(),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: SizedBox(
              height: _tabController.index == 0 ? 280 : 580,
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSignInForm(),
                  _buildSignUpForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabToggle() {
    return AnimatedBuilder(
      animation: _tabController.animation!,
      builder: (context, _) {
        final isSignIn = _tabController.index == 0;
        return Container(
          height: 52,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _tabBtn('Sign In', 0, isSignIn),
              _tabBtn('Sign Up', 1, !isSignIn),
            ],
          ),
        );
      },
    );
  }

  Widget _tabBtn(String label, int index, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: active ? AppConstants.goldGradient : null,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppConstants.gold.withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppConstants.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Welcome back!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your phone number to continue',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _inputField(
            controller: _signInPhoneController,
            label: 'Phone Number',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Sign In',
            isLoading: _isSigningIn,
            icon: Icons.login_rounded,
            isGradient: true,
            onPressed: _handleSignIn,
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _tabController.animateTo(1)),
              child: RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: GoogleFonts.inter(
                    color: AppConstants.textSecondary,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: GoogleFonts.inter(
                        color: AppConstants.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Create Account',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Fill in your details to get started',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _inputField(
                  controller: _signUpFirstNameController,
                  label: 'First Name',
                  icon: Icons.person_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  controller: _signUpLastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _inputField(
            controller: _signUpPhoneController,
            label: 'Phone Number',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _inputField(
            controller: _signUpEmailController,
            label: 'Email Address',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _buildIdProofDropdown(),
          const SizedBox(height: 14),
          _inputField(
            controller: _signUpIdProofNumberController,
            label: 'ID Proof Number',
            icon: Icons.badge_rounded,
          ),
          const SizedBox(height: 14),
          _inputField(
            controller: _signUpAddressController,
            label: 'Address (optional)',
            icon: Icons.location_on_rounded,
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Create Account',
            isLoading: _isSigningUp,
            icon: Icons.person_add_rounded,
            isGradient: true,
            onPressed: _handleSignUp,
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _tabController.animateTo(0)),
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: GoogleFonts.inter(
                    color: AppConstants.textSecondary,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign In',
                      style: GoogleFonts.inter(
                        color: AppConstants.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdProofDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _idProofType,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1F35),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppConstants.gold),
          style: GoogleFonts.inter(color: AppConstants.textPrimary, fontSize: 14),
          hint: Row(
            children: [
              const Icon(Icons.badge_rounded, color: AppConstants.gold, size: 20),
              const SizedBox(width: 12),
              Text('ID Proof Type',
                  style: GoogleFonts.inter(color: AppConstants.textSecondary)),
            ],
          ),
          items: ['Aadhaar', 'Passport', 'Driving License'].map((e) {
            return DropdownMenuItem(
              value: e,
              child: Row(
                children: [
                  const Icon(Icons.badge_rounded,
                      color: AppConstants.gold, size: 20),
                  const SizedBox(width: 12),
                  Text(e),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _idProofType = v!),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: AppConstants.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppConstants.gold, size: 20),
        labelStyle: GoogleFonts.inter(color: AppConstants.textSecondary, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withAlpha(8),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppConstants.gold, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withAlpha(20))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.hotel, color: AppConstants.gold.withAlpha(100), size: 18),
        ),
        Expanded(child: Divider(color: Colors.white.withAlpha(20))),
      ],
    );
  }
}
