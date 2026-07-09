import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room_model.dart';
import '../models/guest_model.dart';
import '../models/booking_model.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  final String _baseUrl = AppConstants.baseUrl;

  Future<List<RoomModel>> getAllRooms() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/rooms'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => RoomModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load rooms: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching rooms: $e');
    }
  }

  Future<List<RoomModel>> getAvailableRooms() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/rooms/available'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => RoomModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load available rooms: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching available rooms: $e');
    }
  }

  Future<List<RoomModel>> getRoomsByType(String roomType) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/rooms/type/$roomType'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => RoomModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load rooms by type: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching rooms by type: $e');
    }
  }

  Future<GuestModel> registerGuest(Map<String, dynamic> guestData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/guests'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(guestData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GuestModel.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to register guest: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error registering guest: $e');
    }
  }

  Future<GuestModel?> findGuestByPhone(String phone) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/guests/phone/$phone'));
      if (response.statusCode == 200) {
        return GuestModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to find guest: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error finding guest: $e');
    }
  }

  Future<BookingModel> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bookingData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingModel.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create booking: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  Future<List<BookingModel>> getBookingsByGuest(String guestId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/bookings/guest/$guestId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => BookingModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load bookings: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<BookingModel> cancelBooking(String bookingId) async {
    try {
      final response = await http.put(Uri.parse('$_baseUrl/api/bookings/$bookingId/cancel'));
      if (response.statusCode == 200) {
        return BookingModel.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to cancel booking: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }
}
