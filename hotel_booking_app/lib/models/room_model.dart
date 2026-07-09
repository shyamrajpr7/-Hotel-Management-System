class RoomModel {
  final String id;
  final String roomNumber;
  final String roomType;
  final double pricePerNight;
  final bool isAvailable;
  final String description;
  final int floorNumber;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.pricePerNight,
    required this.isAvailable,
    required this.description,
    required this.floorNumber,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      roomType: json['roomType'] ?? '',
      pricePerNight: (json['pricePerNight'] ?? 0).toDouble(),
      isAvailable: json['available'] ?? json['isAvailable'] ?? true,
      description: json['description'] ?? '',
      floorNumber: json['floorNumber'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'roomType': roomType,
      'pricePerNight': pricePerNight,
      'isAvailable': isAvailable,
      'description': description,
      'floorNumber': floorNumber,
    };
  }
}
