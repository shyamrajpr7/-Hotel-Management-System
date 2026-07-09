class GuestModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String idProofType;
  final String idProofNumber;
  final String address;

  GuestModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.idProofType,
    required this.idProofNumber,
    required this.address,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    return GuestModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      idProofType: json['idProofType'] ?? '',
      idProofNumber: json['idProofNumber'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'idProofType': idProofType,
      'idProofNumber': idProofNumber,
      'address': address,
    };
  }

  String get fullName => '$firstName $lastName';
}
