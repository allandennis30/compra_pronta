class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final AddressModel address;
  final double latitude;
  final double longitude;
  final bool isSeller;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isSeller = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? json['nome']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? json['telefone']?.toString() ?? '',
        address: json['address'] != null 
            ? AddressModel.fromJson(json['address'])
            : json['endereco'] != null
                ? AddressModel.fromJson(json['endereco'])
                : AddressModel(
                    street: '',
                    number: 0,
                    neighborhood: '',
                    city: '',
                    state: '',
                    zipCode: '',
                  ),
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        isSeller: json['isSeller'] ?? json['istore'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address.toJson(),
        'latitude': latitude,
        'longitude': longitude,
        'isSeller': isSeller,
      };
}

class AddressModel {
  final String street;
  final int number;
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
        street: json['street'] ?? json['rua'] ?? '',
        number: json['number'] is int
            ? json['number']
            : int.tryParse(json['number']?.toString() ??
                    json['numero']?.toString() ??
                    '0') ??
                0,
        complement: json['complement'] ?? json['complemento'],
        neighborhood: json['neighborhood'] ?? json['bairro'] ?? '',
        city: json['city'] ?? json['cidade'] ?? '',
        state: json['state'] ?? json['estado'] ?? '',
        zipCode: json['zipCode'] ?? json['cep'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'rua': street,
        'numero': number,
        'complemento': complement,
        'bairro': neighborhood,
        'cidade': city,
        'estado': state,
        'cep': zipCode,
      };

  String get fullAddress {
    final parts = <String>[];

    if (street.isNotEmpty) parts.add(street);
    if (number.toString().isNotEmpty) parts.add(number.toString());
    if (complement != null && complement!.isNotEmpty) parts.add(complement!);
    if (neighborhood.isNotEmpty) parts.add(neighborhood);
    if (city.isNotEmpty && state.isNotEmpty) {
      parts.add('$city - $state');
    } else if (city.isNotEmpty) {
      parts.add(city);
    } else if (state.isNotEmpty) {
      parts.add(state);
    }
    if (zipCode.isNotEmpty) parts.add(zipCode);

    return parts.isEmpty ? 'Endereço não informado' : parts.join(', ');
  }
}
