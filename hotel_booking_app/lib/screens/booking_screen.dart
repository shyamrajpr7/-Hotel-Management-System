import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/constants.dart';
import '../models/room_model.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class BookingScreen extends StatefulWidget {
  final RoomModel room;
  final String guestId;

  const BookingScreen({super.key, required this.room, required this.guestId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  final _apiService = ApiService();
  final _requestsController = TextEditingController();
  DateTime? _checkIn;
  DateTime? _checkOut;
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  bool _isBooking = false;
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
    _animController.forward();
  }

  @override
  void dispose() {
    _requestsController.dispose();
    _animController.dispose();
    super.dispose();
  }

  int get _nights {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays;
  }

  double get _totalPrice => _nights * widget.room.pricePerNight;

  Future<void> _handleBooking() async {
    if (_checkIn == null || _checkOut == null) {
      _showToast('Please select check-in and check-out dates');
      return;
    }
    if (_nights < 1) {
      _showToast('Check-out must be after check-in');
      return;
    }

    setState(() => _isBooking = true);

    try {
      final bookingData = {
        'guestId': widget.guestId,
        'roomId': widget.room.id,
        'checkInDate': DateFormat('yyyy-MM-dd').format(_checkIn!),
        'checkOutDate': DateFormat('yyyy-MM-dd').format(_checkOut!),
        'specialRequests': _requestsController.text.trim(),
      };

      await _apiService.createBooking(bookingData);
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      _showToast('Booking failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppConstants.goldGradient,
              ),
              child: const Icon(Icons.check, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Booking Confirmed!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your room has been booked successfully.',
              style: GoogleFonts.inter(
                color: AppConstants.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Great!',
              isGradient: true,
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
    final room = widget.room;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppConstants.backgroundGradient),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnim,
            builder: (context, child) => Opacity(
              opacity: _fadeAnim.value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _fadeAnim.value)),
                child: child,
              ),
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(room)),
                SliverToBoxAdapter(child: _buildCalendar()),
                SliverToBoxAdapter(child: _buildSummary()),
                SliverToBoxAdapter(child: _buildBookingButton()),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(RoomModel room) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back, color: AppConstants.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book Room ${room.roomNumber}',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
                Text(
                  '${room.roomType} • ₹${room.pricePerNight.toStringAsFixed(0)}/night',
                  style: GoogleFonts.inter(
                    color: AppConstants.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppConstants.cardDark, Color(0xFF151B2E)],
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
        children: [
          Row(
            children: [
              _buildDateChip('Check In', _checkIn),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, color: AppConstants.gold, size: 20),
              ),
              _buildDateChip('Check Out', _checkOut),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withAlpha(15)),
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _format,
            onFormatChanged: (format) => setState(() => _format = format),
            onPageChanged: (day) => _focusedDay = day,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.playfairDisplay(
                color: AppConstants.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon: const Icon(Icons.chevron_left, color: AppConstants.gold),
              rightChevronIcon: const Icon(Icons.chevron_right, color: AppConstants.gold),
              headerPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              todayDecoration: BoxDecoration(
                color: AppConstants.gold.withAlpha(40),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: AppConstants.gold, fontWeight: FontWeight.bold),
              selectedDecoration: BoxDecoration(
                gradient: AppConstants.goldGradient,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              rangeStartDecoration: BoxDecoration(
                gradient: AppConstants.goldGradient,
                shape: BoxShape.circle,
              ),
              rangeEndDecoration: BoxDecoration(
                gradient: AppConstants.goldGradient,
                shape: BoxShape.circle,
              ),
              rangeStartTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              rangeEndTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              rangeHighlightColor: AppConstants.gold.withAlpha(25),
              withinRangeTextStyle: const TextStyle(color: AppConstants.gold),
              defaultTextStyle: const TextStyle(color: AppConstants.textPrimary),
              weekendTextStyle: const TextStyle(color: AppConstants.textSecondary),
              outsideTextStyle: TextStyle(color: Colors.white.withAlpha(30)),
              rowDecoration: const BoxDecoration(),
            ),
            rangeSelectionMode: RangeSelectionMode.toggledOn,
            selectedDayPredicate: (day) {
              return _checkIn != null && isSameDay(_checkIn, day) ||
                  _checkOut != null && isSameDay(_checkOut, day);
            },
            rangeStartDay: _checkIn,
            rangeEndDay: _checkOut,
            onRangeSelected: (start, end, _) {
              setState(() {
                _checkIn = start;
                _checkOut = end;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, DateTime? date) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppConstants.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Select',
              style: GoogleFonts.inter(
                color: date != null ? AppConstants.textPrimary : AppConstants.textSecondary.withAlpha(120),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _typeColor {
    switch (widget.room.roomType.toLowerCase()) {
      case 'single': return AppConstants.singleColor;
      case 'double': return AppConstants.doubleColor;
      case 'suite': return AppConstants.suiteColor;
      default: return AppConstants.gold;
    }
  }

  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppConstants.cardDark, Color(0xFF151B2E)],
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
          Row(
            children: [
              Text(
                'Booking Summary',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _typeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _typeColor.withAlpha(40)),
                ),
                child: Icon(Icons.hotel, color: _typeColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _summaryRow('Room', '${widget.room.roomNumber} (${widget.room.roomType})'),
          _summaryRow('Price per night', '₹${widget.room.pricePerNight.toStringAsFixed(0)}'),
          _summaryRow('Number of nights', '$_nights'),
          Divider(color: Colors.white.withAlpha(15), height: 24),
          _summaryRow('Total Amount', '₹${_totalPrice.toStringAsFixed(0)}', isTotal: true),
          const SizedBox(height: 16),
          TextFormField(
            controller: _requestsController,
            maxLines: 3,
            style: GoogleFonts.inter(color: AppConstants.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              labelText: 'Special Requests (optional)',
              hintText: 'e.g. Extra pillows, late check-in...',
              prefixIcon: Icon(Icons.chat_bubble_outline, color: AppConstants.gold, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppConstants.textSecondary,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: isTotal ? AppConstants.gold : AppConstants.textPrimary,
              fontSize: isTotal ? 20 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: CustomButton(
        text: 'Confirm Booking',
        icon: Icons.check_circle,
        isLoading: _isBooking,
        isGradient: true,
        onPressed: _handleBooking,
      ),
    );
  }
}
