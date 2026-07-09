import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../models/room_model.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onTap;

  const RoomCard({super.key, required this.room, required this.onTap});

  Color _roomTypeColor() {
    switch (room.roomType.toLowerCase()) {
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

  IconData _roomTypeIcon() {
    switch (room.roomType.toLowerCase()) {
      case 'single':
        return Icons.person;
      case 'double':
        return Icons.people;
      case 'suite':
        return Icons.star;
      default:
        return Icons.hotel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _roomTypeColor();
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: typeColor.withAlpha(25),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  AppConstants.cardDark,
                  Color(0xFF151B2E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withAlpha(25),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageHeader(typeColor),
                _buildDetails(typeColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(Color typeColor) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            typeColor.withAlpha(80),
            typeColor.withAlpha(30),
            AppConstants.cardDark,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.hotel,
              size: 140,
              color: Colors.white.withAlpha(12),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: typeColor.withAlpha(50), width: 1),
              ),
              child: Icon(
                _roomTypeIcon(),
                color: typeColor,
                size: 32,
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: room.isAvailable
                    ? AppConstants.greenAccent.withAlpha(30)
                    : AppConstants.redAccent.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: room.isAvailable
                      ? AppConstants.greenAccent.withAlpha(80)
                      : AppConstants.redAccent.withAlpha(80),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: room.isAvailable
                          ? AppConstants.greenAccent
                          : AppConstants.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    room.isAvailable ? 'Available' : 'Booked',
                    style: GoogleFonts.inter(
                      color: room.isAvailable
                          ? AppConstants.greenAccent
                          : AppConstants.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Room ${room.roomNumber}',
                  style: GoogleFonts.playfairDisplay(
                    color: AppConstants.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    room.roomType,
                    style: GoogleFonts.inter(
                      color: typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(Color typeColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.stairs, size: 16, color: AppConstants.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Floor ${room.floorNumber}',
                      style: GoogleFonts.inter(
                        color: AppConstants.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.door_front_door, size: 16, color: AppConstants.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      room.roomNumber,
                      style: GoogleFonts.inter(
                        color: AppConstants.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  room.description,
                  style: GoogleFonts.inter(
                    color: AppConstants.textSecondary.withAlpha(180),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${room.pricePerNight.toStringAsFixed(0)}',
                style: GoogleFonts.playfairDisplay(
                  color: AppConstants.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '/ night',
                style: GoogleFonts.inter(
                  color: AppConstants.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
