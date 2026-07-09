import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../models/booking_model.dart';
import '../widgets/booking_card.dart';
import '../widgets/shimmer_loader.dart';

class MyBookingsScreen extends StatefulWidget {
  final String guestId;

  const MyBookingsScreen({super.key, required this.guestId});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  final _apiService = ApiService();
  List<BookingModel> _bookings = [];
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
    _loadBookings();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _bookings = await _apiService.getBookingsByGuest(widget.guestId);
      _animController.forward();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Cancel Booking?',
          style: GoogleFonts.playfairDisplay(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel Room ${booking.roomNumber} booking?',
          style: GoogleFonts.inter(color: AppConstants.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('No', style: GoogleFonts.inter(color: AppConstants.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Yes, Cancel', style: GoogleFonts.inter(color: AppConstants.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.cancelBooking(booking.id);
        _showToast('Booking cancelled successfully');
        _loadBookings();
      } catch (e) {
        _showToast('Failed to cancel: ${e.toString()}');
      }
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.cardDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppConstants.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Text(
                  'My Bookings',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '${_bookings.length} booking${_bookings.length != 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    color: AppConstants.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? const ShimmerBookingLoader()
                    : _error != null
                        ? _buildError()
                        : _bookings.isEmpty
                            ? _buildEmpty()
                            : RefreshIndicator(
                                onRefresh: _loadBookings,
                                color: AppConstants.gold,
                                backgroundColor: AppConstants.cardDark,
                                child: AnimatedBuilder(
                                  animation: _fadeAnim,
                                  builder: (context, child) => Opacity(
                                    opacity: _fadeAnim.value,
                                    child: child,
                                  ),
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                                    itemCount: _bookings.length,
                                    itemBuilder: (context, index) {
                                      final booking = _bookings[index];
                                      final delay = (index * 120).clamp(0, 600);
                                      final itemAnim = CurvedAnimation(
                                        parent: _animController,
                                        curve: Interval(
                                          delay / 2000,
                                          (delay + 400) / 2000,
                                          curve: Curves.easeOut,
                                        ),
                                      );
                                      return AnimatedBuilder(
                                        animation: itemAnim,
                                        builder: (context, child) {
                                          return Opacity(
                                            opacity: itemAnim.value,
                                            child: Transform.translate(
                                              offset: Offset(0, 30 * (1 - itemAnim.value)),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: BookingCard(
                                          booking: booking,
                                          onCancel: () => _cancelBooking(booking),
                                        ),
                                      );
                                    },
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

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.white.withAlpha(50)),
            const SizedBox(height: 16),
            Text(
              'Could not load bookings',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.inter(fontSize: 13, color: AppConstants.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _loadBookings,
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
              child: Icon(Icons.book_online, size: 64, color: Colors.white.withAlpha(50)),
            ),
            const SizedBox(height: 20),
            Text(
              'No bookings yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse rooms and book your stay!',
              style: GoogleFonts.inter(
                color: AppConstants.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
