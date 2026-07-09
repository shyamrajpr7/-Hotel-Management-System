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
  String _statusFilter = 'All';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _statusFilters = ['All', 'CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'CANCELLED'];

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

  List<BookingModel> get _filteredBookings {
    if (_statusFilter == 'All') return _bookings;
    return _bookings.where((b) => b.status.toUpperCase() == _statusFilter).toList();
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
    final filtered = _filteredBookings;
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
                  '${filtered.length} booking${filtered.length != 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                    color: AppConstants.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusFilter(),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? const ShimmerBookingLoader()
                    : _error != null
                        ? _buildError()
                        : _bookings.isEmpty
                            ? _buildEmpty()
                            : filtered.isEmpty
                                ? _buildNoMatch()
                                : RefreshIndicator(
                                    onRefresh: _loadBookings,
                                    color: AppConstants.gold,
                                    backgroundColor: AppConstants.cardDark,
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) {
                                        final booking = filtered[index];
                                        return _AnimatedBookingCard(
                                          booking: booking,
                                          index: index,
                                          fadeController: _animController,
                                          onCancel: () => _cancelBooking(booking),
                                        );
                                      },
                                    ),
                                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _statusFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final isSelected = _statusFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _statusFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected ? AppConstants.gold.withAlpha(30) : Colors.white.withAlpha(8),
                border: Border.all(
                  color: isSelected ? AppConstants.gold.withAlpha(80) : Colors.white.withAlpha(15),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filter == 'All' ? filter : filter.replaceAll('_', ' '),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isSelected ? AppConstants.gold : AppConstants.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
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

  Widget _buildNoMatch() {
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
              child: Icon(Icons.search_off, size: 64, color: Colors.white.withAlpha(50)),
            ),
            const SizedBox(height: 20),
            Text(
              'No $_statusFilter bookings',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                color: AppConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBookingCard extends StatefulWidget {
  final BookingModel booking;
  final int index;
  final AnimationController fadeController;
  final VoidCallback onCancel;

  const _AnimatedBookingCard({
    required this.booking,
    required this.index,
    required this.fadeController,
    required this.onCancel,
  });

  @override
  State<_AnimatedBookingCard> createState() => _AnimatedBookingCardState();
}

class _AnimatedBookingCardState extends State<_AnimatedBookingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    final delay = (widget.index * 120).clamp(0, 600);
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          delay / 2000,
          (delay + 400) / 2000,
          curve: Curves.easeOut,
        ),
      ),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          delay / 2000,
          (delay + 400) / 2000,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    if (widget.fadeController.status == AnimationStatus.forward ||
        widget.fadeController.status == AnimationStatus.completed) {
      _controller.forward();
    }
    widget.fadeController.addListener(_onParentChanged);
  }

  void _onParentChanged() {
    if (widget.fadeController.status == AnimationStatus.forward &&
        !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    widget.fadeController.removeListener(_onParentChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacityAnim.value,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - _slideAnim.value.dy)),
          child: child,
        ),
      ),
      child: BookingCard(
        booking: widget.booking,
        onCancel: widget.onCancel,
      ),
    );
  }
}
