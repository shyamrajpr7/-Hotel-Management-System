import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onCancel;
  final bool showCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCancel,
    this.showCancel = true,
  });

  Color _statusColor() {
    switch (booking.status.toUpperCase()) {
      case 'CONFIRMED':
        return AppConstants.greenAccent;
      case 'CHECKED_IN':
        return AppConstants.blueAccent;
      case 'CHECKED_OUT':
        return AppConstants.greyAccent;
      case 'CANCELLED':
        return AppConstants.redAccent;
      default:
        return AppConstants.greyAccent;
    }
  }

  String _statusIcon() {
    switch (booking.status.toUpperCase()) {
      case 'CONFIRMED':
        return '✓';
      case 'CHECKED_IN':
        return '→';
      case 'CHECKED_OUT':
        return '←';
      case 'CANCELLED':
        return '✕';
      default:
        return '•';
    }
  }

  Color _roomTypeColor() {
    switch (booking.roomType.toLowerCase()) {
      case 'single':
        return AppConstants.singleColor;
      case 'double':
        return AppConstants.doubleColor;
      case 'suite':
        return AppConstants.suiteColor;
      default:
        return AppConstants.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final typeColor = _roomTypeColor();
    final checkIn = _tryParseDate(booking.checkInDate);
    final checkOut = _tryParseDate(booking.checkOutDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            AppConstants.cardDark,
            Color(0xFF151B2E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withAlpha(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: typeColor.withAlpha(50)),
                  ),
                  child: Icon(Icons.hotel, color: typeColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room ${booking.roomNumber}',
                        style: GoogleFonts.playfairDisplay(
                          color: AppConstants.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.roomType,
                        style: GoogleFonts.inter(
                          color: AppConstants.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withAlpha(70)),
                  ),
                  child: Text(
                    '${_statusIcon()} ${booking.status}',
                    style: GoogleFonts.inter(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppConstants.surfaceDark.withAlpha(120),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _dateColumn('Check In', checkIn),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 1,
                    height: 40,
                    color: Colors.white.withAlpha(15),
                  ),
                  _dateColumn('Check Out', checkOut),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${booking.totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.playfairDisplay(
                          color: AppConstants.gold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${booking.numberOfNights} night${booking.numberOfNights > 1 ? 's' : ''}',
                        style: GoogleFonts.inter(
                          color: AppConstants.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (booking.specialRequests.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 14, color: AppConstants.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.specialRequests,
                      style: GoogleFonts.inter(
                        color: AppConstants.textSecondary.withAlpha(180),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (showCancel && booking.status == 'CONFIRMED') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(
                    'Cancel Booking',
                    style: GoogleFonts.inter(
                      color: AppConstants.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppConstants.redAccent.withAlpha(15),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppConstants.redAccent.withAlpha(60)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _tryParseDate(String dateStr) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _dateColumn(String label, String value) {
    return Column(
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
          value,
          style: GoogleFonts.inter(
            color: AppConstants.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
