import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../models/room_model.dart';
import '../widgets/custom_button.dart';
import 'booking_screen.dart';

class RoomDetailScreen extends StatefulWidget {
  final RoomModel room;
  final String guestId;

  const RoomDetailScreen({super.key, required this.room, required this.guestId});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  Color get _typeColor {
    switch (widget.room.roomType.toLowerCase()) {
      case 'single': return AppConstants.singleColor;
      case 'double': return AppConstants.doubleColor;
      case 'suite': return AppConstants.suiteColor;
      default: return AppConstants.gold;
    }
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppConstants.backgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildImageHeader(room)),
                  SliverToBoxAdapter(child: _buildContent(room)),
                ],
              ),
              Positioned(
                top: 16,
                left: 16,
                child: AnimatedBuilder(
                  animation: _fadeAnim,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnim.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(120),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withAlpha(20)),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(RoomModel room) {
    return AnimatedBuilder(
      animation: _fadeAnim,
      builder: (context, child) => Opacity(
        opacity: _fadeAnim.value,
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _typeColor,
                _typeColor.withAlpha(100),
                AppConstants.primaryDark,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 40,
                right: -30,
                child: Icon(Icons.hotel, size: 200, color: Colors.white.withAlpha(20)),
              ),
              Positioned(
                top: 80,
                left: 30,
                child: Icon(Icons.star, size: 100, color: Colors.white.withAlpha(12)),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: room.isAvailable
                            ? AppConstants.greenAccent.withAlpha(40)
                            : AppConstants.redAccent.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: room.isAvailable
                              ? AppConstants.greenAccent.withAlpha(100)
                              : AppConstants.redAccent.withAlpha(100),
                        ),
                      ),
                      child: Text(
                        room.isAvailable ? 'Available' : 'Booked',
                        style: GoogleFonts.inter(
                          color: room.isAvailable
                              ? AppConstants.greenAccent
                              : AppConstants.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Room ${room.roomNumber}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _typeColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            room.roomType,
                            style: GoogleFonts.inter(
                              color: _typeColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Floor ${room.floorNumber}',
                          style: GoogleFonts.inter(
                            color: Colors.white.withAlpha(160),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(RoomModel room) {
    return AnimatedBuilder(
      animation: _slideAnim,
      builder: (context, child) => SlideTransition(
        position: _slideAnim,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryDark,
              AppConstants.primaryDark,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price per Night',
                      style: GoogleFonts.inter(
                        color: AppConstants.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${room.pricePerNight.toStringAsFixed(0)}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.gold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            '/night',
                            style: GoogleFonts.inter(
                              color: AppConstants.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _typeColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _typeColor.withAlpha(50)),
                  ),
                  child: Icon(Icons.hotel, color: _typeColor, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.surfaceDark.withAlpha(120),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    room.description,
                    style: GoogleFonts.inter(
                      color: AppConstants.textSecondary.withAlpha(200),
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildInfoChip(Icons.meeting_room, 'Room ${room.roomNumber}'),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.stairs, 'Floor ${room.floorNumber}'),
                const SizedBox(width: 12),
                _buildInfoChip(
                  Icons.category,
                  room.roomType,
                ),
              ],
            ),
            if (!room.isAvailable) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.redAccent.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppConstants.redAccent.withAlpha(40)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block, color: AppConstants.redAccent, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'This room is currently booked',
                      style: GoogleFonts.inter(
                        color: AppConstants.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            CustomButton(
              text: room.isAvailable ? 'Book Now' : 'Not Available',
              icon: room.isAvailable ? Icons.calendar_today : Icons.block,
              onPressed: room.isAvailable
                  ? () => _openBooking(room)
                  : null,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppConstants.gold),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppConstants.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _openBooking(RoomModel room) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => BookingScreen(
          room: room,
          guestId: widget.guestId,
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
