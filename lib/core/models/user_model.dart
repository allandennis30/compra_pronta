class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final AddressModel address;
  final double latitude;
  final double longitude;
  final bool istore;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.istore = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    address: AddressModel.fromJson(json['address']),
    latitude: json['latitude'],
    longitude: json['longitude'],
    istore: json['istore'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address.toJson(),
    'latitude': latitude,
    'longitude': longitude,
    'istore': istore,
  };
}

class AddressModel {
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;

  AddressModel({
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    street: json['street'],
    number: json['number'],
    complement: json['complement'],
    neighborhood: json['neighborhood'],
    city: json['city'],
    state: json['state'],
    zipCode: json['zipCode'],
  );

  Map<String, dynamic> toJson() => {
    'street': street,
    'number': number,
    'complement': complement,
    'neighborhood': neighborhood,
    'city': city,
    'state': state,
    'zipCode': zipCode,
  };

  String get fullAddress => '$street, $number${complement != null ? ' - $complement' : ''}, $neighborhood, $city - $state, $zipCode';
} 