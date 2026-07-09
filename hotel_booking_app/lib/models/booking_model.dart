class BookingModel {
  final String id;
  final String guestId;
  final String guestName;
  final String roomId;
  final String roomNumber;
  final String roomType;
  final String checkInDate;
  final String checkOutDate;
  final int numberOfNights;
  final double pricePerNight;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String bookedAt;
  final String specialRequests;

  BookingModel({
    required this.id,
    required this.guestId,
    required this.guestName,
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
    required this.pricePerNight,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.bookedAt,
    required this.specialRequests,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      guestId: json['guestId'] ?? '',
      guestName: json['guestName'] ?? '',
      roomId: json['roomId'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      roomType: json['roomType'] ?? '',
      checkInDate: json['checkInDate'] ?? '',
      checkOutDate: json['checkOutDate'] ?? '',
      numberOfNights: json['numberOfNights'] ?? 0,
      pricePerNight: (json['pricePerNight'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'CONFIRMED',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      bookedAt: json['bookedAt'] ?? '',
      specialRequests: json['specialRequests'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guestId': guestId,
      'guestName': guestName,
      'roomId': roomId,
      'roomNumber': roomNumber,
      'roomType': roomType,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'numberOfNights': numberOfNights,
      'pricePerNight': pricePerNight,
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'bookedAt': bookedAt,
      'specialRequests': specialRequests,
    };
  }
}
